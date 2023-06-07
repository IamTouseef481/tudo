defmodule CoreWeb.Controllers.JobController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Bids, BSP, Employees, Invoices, Jobs, Payments, Promotions, Services}
  alias Core.Schemas.JobCategory
  alias Core.Jobs.{JobNotificationHandler, SettingsPicker}
  alias CoreWeb.GraphQL.Resolvers.{PromotionResolver, SearchBSPResolver}
  alias CoreWeb.Helpers.{JobHelper, JobNoteHelper}

  @default_error ["unexpected error occurred"]

  def post_job(input) do
    with {:ok, input} <- check_compulsory_foreign_keys_for_post_job(input),
         input <- SearchBSPResolver.adjust_arrive_at_according_slot(input),
         {:ok, bs_data} <- get_data_by_branch_service_id(input),
         {:ok, ewd} <- SettingsPicker.add_ewd_in_params(bs_data) do
      #      Using branch_service_id, implement a big query to fetch all the data in one go!

      input
      |> Map.merge(ewd)
      |> check_multiple_and_post_job(bs_data)
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["something went wrong"], __ENV__.line)
    end
  end

  defp map_branch_service_data(data) when is_list(data) do
    branch_id = data |> hd() |> Map.get(:branch_id)

    Enum.reduce(data, %{service_ids: [], country_service_ids: [], branch_service_ids: []}, fn d,
                                                                                              acc ->
      bs_id = List.insert_at(acc[:branch_service_ids], -1, d[:branch_service_id])
      s_id = List.insert_at(acc[:service_ids], -1, d[:service_id])
      cs_id = List.insert_at(acc[:country_service_ids], -1, d[:country_service_id])
      Map.merge(acc, %{country_service_ids: cs_id, service_ids: s_id, branch_service_ids: bs_id})
    end)
    |> Map.merge(%{branch_id: branch_id})
  end

  defp map_branch_service_data(data), do: data

  def get_data_by_branch_service_id(%{branch_service_ids: bs_ids, branch_id: branch_id})
      when is_list(bs_ids) do
    case BSP.get_all_branch_service_data(bs_ids, branch_id) do
      [] -> {:error, ["No Records Found against the branch_service_ids"]}
      data -> {:ok, data}
    end
  end

  #  single service
  def get_data_by_branch_service_id(%{branch_service_id: bs_id, branch_id: branch_id}) do
    case BSP.get_all_branch_service_data(bs_id, branch_id) do
      %{} = data -> {:ok, data}
      nil -> {:error, ["No Data Found against the branch_service_id"]}
    end
  end

  def update_job(input) do
    with {:ok, input} <- make_ticket_no(input),
         {:ok, input} <- add_time_related_to_job_status(input),
         {:ok, input} <- SettingsPicker.make_completed_job_cost(input) do
      with {:ok, _last, all} <- JobHelper.update_job(input),
           %{job: data, is_job_exist: previous_job, rescheduling_statuses: params} <- all,
           _ <-
             JobNotificationHandler.send_notification_for_update_job(previous_job, data, params) do
        data =
          case Invoices.get_invoice_by_job_id(data.id) do
            [] ->
              Map.merge(data, %{invoice_id: nil, invoice_amount: nil})

            [%{id: invoice_id, final_amount: amount}] ->
              Map.merge(data, %{invoice_id: invoice_id, invoice_amount: amount})

            _ ->
              data
          end

        data = location_dest(data)
        data = location_src(data)
        {hours, minutes, seconds} = Time.to_erl(data.expected_work_duration)
        ewd_int = hours * 3600 + minutes * 60 + seconds
        job = Map.merge(data, %{ewd_int: ewd_int})

        {
          :ok,
          job
          #          CurrencyConversions.update_currency_fields(job, %{job_id: job.id})
        }
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, exception, __ENV__.line)
  end

  @doc """
    check_multiple_and_post_job
    this function does post job for multiple services
    on is_multiple: true, jobs will be posted separately for each service type
    on is_multiple: false, jobs will be posted for each grouped service type

  [Quick View Of This Function]
  -> jobs will be posted separately for each service type
  -> jobs will be posted for each grouped service type
  """
  def check_multiple_and_post_job(input, bs_data) do
    case get(input, :is_multiple) do
      true -> when_true(input, bs_data)
      false -> when_false(input, bs_data)
      _ -> default_case(input, bs_data)
    end
  end

  def when_true(input, bs_data) do
    input = Map.drop(input, [:branch_service_ids])

    Enum.reduce_while(bs_data, [], fn
      data, acc ->
        data =
          Map.put(data, :branch_service_ids, [data.branch_service_id])
          |> Map.drop([:branch_service_id])

        input
        |> Map.merge(data)
        |> job_post()
        |> handle_resp(acc)
    end)
  end

  def when_false(input, bs_data) do
    grouped_data = group_by_service_types(bs_data)

    Enum.reduce_while(grouped_data, [], fn
      {s_type, value}, acc ->
        input
        |> Map.merge(map_branch_service_data(value))
        |> Map.merge(%{service_type_id: s_type})
        |> job_post()
        |> handle_resp(acc)
    end)
  end

  def default_case(input, bs_data) when is_list(bs_data) do
    when_false(input, bs_data)
  end

  def default_case(input, bs_data) when is_map(bs_data) do
    input
    |> Map.merge(map_branch_service_data(bs_data))
    |> Map.merge(%{service_type_id: bs_data.service_type_id})
    |> job_post()
  end

  defp group_by_service_types(data), do: Enum.group_by(data, fn d -> d.service_type_id end)

  defp job_post(input) do
    with {:ok, input} <- SettingsPicker.make_job_cost(input),
         {:ok, _last, all} <- JobHelper.create_job(input),
         %{chat_data: data, job: job} <- all,
         _ <- JobNotificationHandler.send_notification_for_create_job(job, input) do
      data = location_dest(data) |> location_src() |> attach_promotion_to_job(input)
      {hours, minutes, seconds} = Time.to_erl(data.expected_work_duration)
      ewd_int = hours * 3600 + minutes * 60 + seconds
      job = Map.merge(data, %{ewd_int: ewd_int})

      {
        :ok,
        job
        # CurrencyConversions.update_currency_fields(job, %{job_id: job.id})
      }
    else
      {:error, error} ->
        {:error, error}

      error ->
        logger(__MODULE__, error, error, __ENV__.line)
    end
  end

  defp handle_resp({:error, error}, _), do: {:halt, error}

  defp handle_resp({:ok, job}, acc), do: (acc ++ [job]) |> continue

  defp handle_resp(_, _), do: {:halt, ["error in multiple job posting"]}

  defp attach_promotion_to_job(data, %{promotion_id: promotion_id}) do
    case Promotions.get_promotion(promotion_id) do
      %{} = promotion -> Map.merge(data, %{deal: promotion})
      _ -> data
    end
  end

  defp attach_promotion_to_job(data, _input), do: data

  def check_compulsory_foreign_keys_for_post_job(parameters) do
    with {:ok, _} <- get_job_category_for_job_post(parameters),
         {:ok, _} <- get_bidding_proposal(parameters),
         {:ok, _} <- get_promotion(parameters) do
      parameters |> ok
    else
      {:error, err} ->
        err |> error

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  end

  @doc """
    get_service_type
    get single service type or multiple service types

   ##Examples
  ```elixir
    iex> get_service_type(1)
    iex> get_service_type([1, 2, 3])
  ```
  [Quick View Of This Function]
  -> get service types for single service or multiple services
  """
  def get_service_type(input) do
    id = input[:service_type_ids] || input[:service_type_id]
    Services.get_service_type(id) |> default_resp(msg: ["Service type doesn't exist!"])
  end

  @doc """
    get_service
    get single service or multiple services

   ##Examples
  ```elixir
    iex> get_service(1)
    iex> get_service([1, 2, 3])
  ```
  [Quick View Of This Function]
  -> get service for single id or multiple ids
  """
  def get_service(input) do
    id = input[:service_ids] || input[:service_id]
    Services.get_service(id) |> default_resp(msg: ["service doesn't exist!"])
  end

  def get_branch(%{branch_id: branch_id}) do
    BSP.get_branch!(branch_id)
    |> then(fn
      nil ->
        error(["Business Branch doesn't exist!"])

      %{status_id: "confirmed"} = branch ->
        ok(branch)

      %{status_id: _} ->
        error(["branch is not approved"])

      _ ->
        error(@default_error)
    end)
  end

  def get_branch(params), do: ok(params)

  def get_branch_service(input) do
    id = input[:branch_service_ids] || input[:branch_service_id]
    Services.get_branch_service(id) |> default_resp(msg: ["branch service doesn't exist!"])
  end

  def get_job_category_for_job_post(%{job_category_id: job_category_id}),
    do:
      Jobs.get_job_category(job_category_id)
      |> default_resp(msg: ["This Job category doesn't exist!"])

  def get_job_category_for_job_post(params), do: ok(params)

  def get_bidding_proposal(%{bidding_proposal_id: bidding_proposal_id}),
    do:
      Bids.get_bid_proposal(bidding_proposal_id)
      |> default_resp(msg: ["This Bidding proposal doesn't exist!"])

  def get_bidding_proposal(params), do: ok(params)

  def get_promotion(%{promotion_id: promotion_id}),
    do: Promotions.get_promotion(promotion_id) |> default_resp(msg: ["Promotion doesn't exist!"])

  def get_promotion(params), do: ok(params)

  def get_branch_by_employee(employee_id) do
    case BSP.get_branch_by_employee_id(employee_id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def get_employee_jobs(employee) do
    if employee.employee_role_id == "branch_manager" do
      case Employees.get_employees_by_manager(employee.manager_id) do
        [] ->
          Jobs.get_employee_jobs(employee.id)

        manage_employee ->
          employee_ids =
            Enum.reduce(manage_employee, [], fn m_e, acc ->
              case Employees.get_employee(m_e.employee_id) do
                nil -> acc
                _employee -> [m_e.employee_id | acc]
              end
            end)

          employee_jobs =
            Enum.reduce(employee_ids, [], fn employee_id, acc ->
              jobs = Jobs.get_employee_jobs(employee_id)
              acc ++ jobs
            end)

          manager_jobs = Jobs.get_employee_jobs(employee.id)
          manager_employee_jobs = employee_jobs ++ manager_jobs
          #          employee_jobs = Enum.group_by(employee_jobs, & &1.employee_id)
          manager_employee_jobs
      end
    else
      Jobs.get_employee_jobs(employee.id)
    end
  end

  def get_cmr_jobs(jobs) do
    jobs = get_jobs(jobs)

    Enum.map(jobs, fn %{id: job_id} = job ->
      job =
        Map.merge(job, %{branch_service: snake_keys_to_camel(job.branch_services)})
        |> add_deal_to_job()
        |> preload_cmr_and_branch()

      amounts =
        case Invoices.get_invoice_by_job_id(job_id) do
          [] ->
            %{invoice_id: nil, invoice_amount: nil}

          [%{id: invoice_id, final_amount: amount}] ->
            case Payments.get_payment_by_invoice_id(invoice_id) do
              %{id: payment_id, total_transaction_amount: paid_amount} ->
                %{
                  payment_id: payment_id,
                  invoice_id: invoice_id,
                  invoice_amount: amount,
                  cmr_paid_amount: paid_amount
                }

              _ ->
                %{invoice_id: invoice_id, invoice_amount: amount}
            end

          _ ->
            %{}
        end

      Map.merge(job, amounts)
    end)
  end

  def get_bsp_jobs(%{user_id: _user_id} = input) do
    {:ok,
     Jobs.get_jobs_for_bsp(input)
     |> get_jobs()
     |> merge_required_data_in_jobs()}
  end

  def get_bsp_jobs(%{employee_id: employee_id, current_user_id: user_id} = input) do
    %{branch_id: employee_branch_id} = Employees.get_employee(employee_id)
    employees = Employees.get_employees_by_user_id(user_id)

    valid_to_get_jobs =
      Enum.reduce_while(employees, [], fn %{id: id}, _acc ->
        %{branch_id: branch_id} = Employees.get_employee(id)

        if employee_branch_id == branch_id do
          {:halt, true}
        else
          {:cont, false}
        end
      end)

    if valid_to_get_jobs == true do
      {:ok,
       Jobs.get_jobs_for_bsp(input)
       |> get_jobs()
       |> merge_required_data_in_jobs()}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  #  common function in both jobs for cmr and bsp
  def get_jobs(jobs) do
    Enum.map(jobs, fn job ->
      bs_data =
        Jobs.get_branch_services_for_bsp(
          Map.get(job, :branch_service_ids) || job.branch_service_id
        )
        |> process_location()
        |> case do
          bs_data when is_map(bs_data) -> [bs_data]
          bs_data -> bs_data
        end

      Map.merge(job, %{branch_services: bs_data})
    end)
  end

  def merge_required_data_in_jobs(jobs) do
    Enum.map(jobs, fn job ->
      job =
        Map.merge(job, %{branch_service: snake_keys_to_camel(job.branch_services)})
        |> preload_cmr_and_branch()
        |> add_deal_to_job()

      case Invoices.get_invoice_by_job_id(job.id) do
        [] ->
          Map.merge(job, %{invoice_id: nil, invoice_amount: nil})

        [%{id: invoice_id, final_amount: amount}] ->
          case Payments.get_payment_by_invoice_id(invoice_id) do
            %{id: payment_id, payment_method_id: payment_method_id} ->
              Map.merge(job, %{
                invoice_id: invoice_id,
                invoice_amount: amount,
                payment_id: payment_id,
                payment_method_id: payment_method_id
              })

            _ ->
              Map.merge(job, %{invoice_id: invoice_id, invoice_amount: amount})
          end

        _ ->
          job
      end
    end)
  end

  defp process_location(bs_data) when is_list(bs_data),
    do: Enum.map(bs_data, &process_location(&1))

  defp process_location(bs_data) do
    %{coordinates: {long, lat}} = bs_data.branch_location
    %{bs_data | branch_location: %{lat: lat, long: long}}
  end

  @doc """
    insert_branch_service
    put branch service to the job

  [Quick View Of This Function]
  -> get lat, longs from branch service and insert into job
  """
  def insert_branch_service(bs_data, job) do
    bs_data
    |> get(:branch_location)
    |> then(fn %{coordinates: {long, lat}} ->
      bs_data |> put(:branch_location, %{lat: lat, long: long})
    end)
    |> then(fn bs_data -> job |> put(:branch_service, bs_data) end)
  end

  # def preload_cmr_and_branch(%{inserted_by: user_id, branch_service_id: nil} = job),
  #   do: add_cmr_and_ewd_to_job(job, user_id)

  def preload_cmr_and_branch(%{inserted_by: user_id, branch_service_id: branch_service_id} = job) do
    if is_nil(Map.get(job, :branch_service_ids)) do
      branch_service_id
      |> Core.Services.get_branch_service()
      |> get(:branch_id)
      |> Core.BSP.get_branch!()
      |> Map.delete(:search_tsvector)
      |> then(fn branch ->
        if is_struct(branch), do: job |> put(:branch, add_geo(branch)), else: job
      end)
      |> add_cmr_and_ewd_to_job(user_id)
    else
      branches =
        job.branch_service_ids
        |> Core.Services.get_branch_service()
        |> get(:branch_id)
        |> Enum.uniq()
        |> Core.BSP.list_branches_by_ids()
        |> Enum.map(&Map.delete(&1, :search_tsvector))

      case length(branches) do
        1 ->
          hd(branches)
          |> then(fn branch ->
            if is_struct(branch), do: job |> put(:branch, add_geo(branch)), else: job
          end)

        0 ->
          job

        _ ->
          branches =
            Enum.reduce(branches, [], fn branch, acc ->
              if is_struct(branch), do: [add_geo(branch) | acc], else: acc
            end)

          Map.merge(job, %{branches: branches})
      end
      #      |> then(fn branches -> if is_struct(branches), do: job |> put(:branch, add_geo(branches)), else: job end)
      |> add_cmr_and_ewd_to_job(user_id)
    end
  end

  def preload_cmr_and_branch(%{inserted_by: user_id} = job),
    do: add_cmr_and_ewd_to_job(job, user_id)

  defp add_cmr_and_ewd_to_job(job, user_id) do
    job
    |> add_cmr_to_job(user_id)
    |> add_parsed_ewd_to_job()
  end

  ###############################################
  # Converts and add user profile
  # from struct to camel_case_keys into job
  ###############################################
  defp add_cmr_to_job(job, user_id) do
    case Core.Accounts.get_user!(user_id) do
      %{profile: profile} = user ->
        user
        |> put(:profile, snake_keys_to_camel(profile))
        |> then(fn user -> job |> put(:cmr, user) end)

      _ ->
        job
    end
  end

  ###############################################
  # Converts and add Expected Work Duration (ewd)
  # from struct to integer into Job
  ###############################################
  defp add_parsed_ewd_to_job(job) do
    job
    |> get(:expected_work_duration)
    |> then(fn ewd -> if is_struct(ewd), do: ewd, else: Time.from_iso8601!(ewd) end)
    |> then(fn ewd -> ewd |> Time.to_erl() end)
    |> then(fn {hours, minutes, seconds} -> hours * 3600 + minutes * 60 + seconds end)
    |> then(fn ewd_int -> job |> put(:ewd_int, ewd_int) end)
  end

  # this function only adds deal from which job is created, job has record of that promotion
  def add_deal_to_job(job) do
    with true <- Map.has_key?(job, :promotion_id),
         true <- is_integer(job.promotion_id),
         %{} = promotion <- Promotions.get_promotion(job.promotion_id) do
      case Services.get_branch_service(job.branch_service_id) do
        %{branch_id: branch_id} ->
          %{country_id: country_id} = BSP.get_branch!(branch_id)
          [promotion] = PromotionResolver.attach_services_to_promotions([promotion], country_id)
          Map.merge(job, %{deal: promotion})
      end
    else
      _ -> job
    end
  end

  def create_job_category(input) do
    if owner_or_manager_validity(input) do
      case Jobs.create_job_category(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_job_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_category(id) do
        nil -> {:error, ["This Job category doesn't exist!"]}
        %{} = job_category -> {:ok, job_category}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_job_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_category(id) do
        nil -> {:error, ["This Job category doesn't exist!"]}
        %{} = job_category -> Jobs.update_job_category(job_category, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_job_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_category(id) do
        nil -> {:error, ["This Job category doesn't exist!"]}
        %{} = job_category -> Jobs.delete_job_category(job_category)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_job_status(input) do
    if owner_or_manager_validity(input) do
      case Jobs.create_job_status(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_job_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_status(id) do
        nil -> {:error, ["Job status you are trying doesn't exist!"]}
        %{} = job_status -> {:ok, job_status}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_job_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_status(id) do
        nil -> {:error, ["Job status you are trying doesn't exist!"]}
        %{} = job_status -> Jobs.update_job_status(job_status, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_job_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Jobs.get_job_status(id) do
        nil -> {:error, ["Job status you are trying doesn't exist!"]}
        %{} = job_status -> Jobs.delete_job_status(job_status)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  defp make_ticket_no(%{id: job_id} = params) do
    case params do
      %{job_status_id: "started_working"} -> making_ticket_no(job_id, params)
      %{job_cmr_status_id: "on_board"} -> making_ticket_no(job_id, params)
      %{job_bsp_status_id: "on_board"} -> making_ticket_no(job_id, params)
      _ -> {:ok, params}
    end
  end

  defp making_ticket_no(job_id, params) do
    case Jobs.get_job(job_id) do
      nil ->
        {:error, ["job doesn't exist!"]}

      %{employee_id: employee_id} when employee_id != nil ->
        case Employees.get_employee(employee_id) do
          nil ->
            {:error, ["employee doesn't exist!"]}

          %{branch_id: branch_id} when branch_id != nil ->
            today_jobs_count = Jobs.get_single_day_branch_jobs_count(branch_id)
            {:ok, Map.merge(params, %{ticket_no: today_jobs_count + 1})}

          _ ->
            {:error, ["enable to fetch employee"]}
        end

      _ ->
        {:error, ["Can't get job!"]}
    end
  end

  defp add_time_related_to_job_status(%{job_status_id: "completed"} = input) do
    {:ok, Map.merge(input, %{completed_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "confirmed"} = input) do
    {:ok, Map.merge(input, %{confirmed_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "cancelled"} = input) do
    {:ok, Map.merge(input, %{cancelled_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "started_working"} = input) do
    {:ok, Map.merge(input, %{started_working_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "rejected"} = input) do
    {:ok, Map.merge(input, %{rejected_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "accept"} = input) do
    {:ok, Map.merge(input, %{approved_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(%{job_status_id: "picked"} = input) do
    {:ok, Map.merge(input, %{picked_at: DateTime.utc_now()})}
  end

  defp add_time_related_to_job_status(input) do
    {:ok, input}
  end

  def index(conn, _params) do
    job_categories = Jobs.list_job_categories()
    render(conn, "index.html", job_categories: job_categories)
  end

  def new(conn, _params) do
    changeset = Jobs.change_job_category(%JobCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job_category" => job_category_params}) do
    case Jobs.create_job_category(job_category_params) do
      {:ok, _job_category} ->
        conn
        |> put_flash(:info, "Job category created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job_category = Jobs.get_job_category!(id)
    render(conn, "show.html", job_category: job_category)
  end

  def edit(conn, %{"id" => id}) do
    job_category = Jobs.get_job_category!(id)
    changeset = Jobs.change_job_category(job_category)
    render(conn, "edit.html", job_category: job_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "job_category" => job_category_params}) do
    job_category = Jobs.get_job_category!(id)

    case Jobs.update_job_category(job_category, job_category_params) do
      {:ok, _job_category} ->
        conn
        |> put_flash(:info, "Job category updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", job_category: job_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    job_category = Jobs.get_job_category!(id)
    {:ok, _job_category} = Jobs.delete_job_category(job_category)

    conn
    |> put_flash(:info, "Job category deleted successfully.")
  end

  def create_job_note(input) do
    case JobNoteHelper.create_job_note(input) do
      {:ok, _last, %{create_job_note: data}} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def show_job_note(input) do
    case JobNoteHelper.show_job_note(input) do
      {:ok, _last, %{show_job_note: data}} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
