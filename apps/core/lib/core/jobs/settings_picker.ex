defmodule Core.Jobs.SettingsPicker do
  @moduledoc false

  use CoreWeb, :core_resolver

  alias Core.{Bids, Jobs, Settings}
  alias CoreWeb.Controllers.{JobController, SearchBSPController}

  require Logger

  @default_time ~T[00:30:00]
  @cost_error ["Unable to determine Estimated Cost, try again"]

  @doc """
    add_ewd_in_params()
    Get and Add All ewd's for the branch_service_ids or branch_service_id,
    this function will add all the ewds for multiple branches in multiple services

  [Overview]
  -> get_list of services against branches and add the ewd to params
  -> multiple services clause
  -> single service clause
  """
  def add_ewd_in_params(bs_data) when is_list(bs_data) do
    ewd =
      Enum.reduce(bs_data, ~T[00:00:00], fn
        %{branch_id: branch_id, country_service_id: cs_id, service_type_id: service_type}, acc ->
          # add all ewd s to make single ewd for multiple_services
          adds_ewd_in_params(branch_id, cs_id, service_type) |> add(acc)
      end)

    %{expected_work_duration: ewd} |> ok()
  end

  def add_ewd_in_params(%{
        branch_id: branch_id,
        country_service_id: cs_id,
        service_type_id: s_type_id
      }) do
    ewd = adds_ewd_in_params(branch_id, cs_id, s_type_id)
    %{expected_work_duration: ewd} |> ok()
  end

  def add_ewd_in_params(_input),
    do: error(["Branch Service id missing to read Service Duration from settings"])

  def adds_ewd_in_params(bsp, branch_id, branch_services, input) when is_list(branch_services) do
    Settings.get_settings_by(%{branch_id: branch_id, slug: "services_expected_work_duration"})
    |> then(fn
      %{fields: fields} ->
        Enum.reduce(branch_services, ~T[00:00:00], fn %{
                                                        country_service_id: cs_id,
                                                        service_type_id: service_type_id
                                                      },
                                                      acc ->
          case service_type_id do
            "on_demand" ->
              bsp = SearchBSPController.calculate_ewd_for_on_demand(bsp, input)

              if Map.has_key?(bsp, :expected_work_duration),
                do: bsp.expected_work_duration,
                else: ~T[00:00:00]

            service_type_id ->
              if fields["same_for_all_for_#{service_type_id}"] do
                ewd =
                  Time.from_iso8601(fields["default_for_#{service_type_id}"])
                  |> default_resp(mode: :custom, default: false, any: @default_time)

                add(acc, ewd)
              else
                ewd =
                  Enum.reduce(
                    fields["services"]["#{service_type_id}"],
                    ~T[00:00:00],
                    fn service_type, acc ->
                      #              if cs_id == service["country_service_id"], do: {:halt, service["expected_work_duration"]}, else: {:cont, acc}
                      check_country_services(service_type, acc, cs_id)
                    end
                  )

                Time.from_iso8601(ewd)
                |> default_resp(mode: :custom, default: false, any: @default_time)
              end
          end
        end)

      _ ->
        @default_time
    end)
  end

  def adds_ewd_in_params(branch_id, cs_id, service_type) do
    Settings.get_settings_by(%{branch_id: branch_id, slug: "services_expected_work_duration"})
    |> then(fn
      %{fields: fields} ->
        if fields["same_for_all_for_#{service_type}"] do
          Time.from_iso8601(fields["default_for_#{service_type}"])
          |> default_resp(mode: :custom, default: false, any: @default_time)
        else
          Enum.reduce(fields["services"]["#{service_type}"], ~T[00:00:00], fn service, acc ->
            #              if cs_id == service["country_service_id"], do: {:halt, service["expected_work_duration"]}, else: {:cont, acc}
            check_country_services(service, acc, cs_id)
          end)
          |> ok()
          |> default_resp(mode: :custom, default: false, any: @default_time)
        end

      _ ->
        @default_time
    end)
  end

  def adds_ewd_in_params(_input),
    do: error(["Branch Service id missing to read Service Duration from settings"])

  defp check_country_services(service, acc, cs_id) when is_list(cs_id) do
    if service["country_service_id"] in cs_id,
      do: Time.from_iso8601!(service["expected_work_duration"]) |> add(acc),
      else: acc
  end

  defp check_country_services(service, acc, cs_id) do
    if cs_id == service["country_service_id"],
      do: Time.from_iso8601!(service["expected_work_duration"]) |> add(acc),
      else: acc
  end

  def make_job_cost(%{bidding_proposal_id: proposal_id} = input) do
    input
    |> then(fn
      %{cost: _} ->
        input |> ok

      _ ->
        Bids.get_bid_proposal(proposal_id)
        |> then(fn
          %{cost: cost} ->
            input |> put(:cost, cost) |> ok

          _ ->
            error([
              "Estimated Cost is missing in params and error in fetching Bidding proposal to determine Estimated cost"
            ])
        end)
    end)
  end

  def make_job_cost(%{cost: _} = input), do: input |> ok()

  def make_job_cost(
        %{branch_id: branch_id, service_type_id: type, country_service_ids: cs_ids} = input
      ) do
    case get_settings_by(branch_id, "service_cost_estimate") do
      {:ok, %{fields: fields}} ->
        make_cost(input, fields, type, cs_ids, input.expected_work_duration, "cost")

      {:error, err} ->
        error(err)

      _ ->
        error(["Unable to determine Estimated Cost, try again"])
    end
  end

  def make_job_cost(
        %{branch_id: branch_id, service_type_id: type, country_service_id: cs_id} = input
      ) do
    case get_settings_by(branch_id, "service_cost_estimate") do
      {:ok, %{fields: fields}} ->
        make_cost(input, fields, type, cs_id, input.expected_work_duration, "cost")

      {:error, err} ->
        error(err)

      _ ->
        error(["Unable to determine Estimated Cost, try again"])
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @cost_error, __ENV__.line)
  end

  def make_job_cost(
        %{branch_id: branch_id, service_type_ids: types, country_service_ids: cs_ids} = input
      ) do
    case get_settings_by(branch_id, "service_cost_estimate") do
      {:ok, %{fields: fields}} ->
        make_cost(input, fields, types, cs_ids, input.expected_work_duration, "cost")

      {:error, err} ->
        error(err)

      _ ->
        error(["Unable to determine Estimated Cost, try again"])
    end
  end

  @doc """
    make_cost
    add costs for all the country services and single country service
    this will sum up all the services cost and return the input

    [Overview]
    -> for multiple services, [country_service_ids]
    -> for single service
  """

  def make_cost(input, fields, types, cs_id, _working_time, cost_key) when is_list(types) do
    Enum.reduce_while(types, input |> put(:cost, 0), fn
      type, %{cost: prev_cost} = acc ->
        make_cost(input, fields, type, cs_id, input.expected_work_duration, cost_key)
        |> then(fn
          {:ok, %{cost: cost}} ->
            acc |> put(:cost, prev_cost + cost) |> continue

          {:error, err} ->
            Logger.error("#{__MODULE__} - error #{inspect(err)}")
            acc |> halt
        end)
    end)
    |> ok
  end

  def make_cost(input, fields, type, cs_id, _working_time, cost_key) do
    #    common for all 3 service_types
    if type in ["walk_in", "on_demand", "home_service"] do
      Enum.filter(fields["services_estimates"]["#{type}"], &filter_service(&1, cs_id))
      |> handle_service_price(input, cost_key)
    else
      error(["invalid service type"])
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @cost_error, __ENV__.line)
  end

  @doc """
    handle_service_price
    to handle service prices and sum up the costs for service and multiple_services

   ##Examples
  ```elixir
  service_price =
    [
      %{
          "country_service_id" => 314,
          "duration_minutes" => 30,
          "final_amount" => 50.0,
          "name" => "Fast food",
          "price_amount" => 100.0
      }
    ]
  input = [input from mutation]
  cost_key = [cost will be merged against this key]
  iex> handle_service_price(service_price, input, cost_key)
  ```
  [Quick View Of This Function]
  -> for multiple_services sum up all the costs and merge into the input
  -> for single service cost add into input
  -> will return the input
  """

  def handle_service_price(service_price, input, cost_key) when is_list(service_price) do
    cost = service_price |> get("final_amount") |> Enum.sum()
    input |> put(String.to_existing_atom("#{cost_key}"), cost) |> ok()
  end

  def handle_service_price([%{"final_amount" => cost}], input, cost_key),
    do: input |> put(String.to_existing_atom("#{cost_key}"), cost) |> ok()

  def handle_service_price([], _, _),
    do: ["Estimated Cost not found in settings against the Service"] |> error()

  def handle_service_price(_, _, _),
    do: error(["Multiple records found in settings against provided data"])

  @doc """
    filter_services on bases of country_service_id or ids

    [Overview]
    -> when country_service_ids is list
    -> when country_service_id
  """
  def filter_service(service, cs_id) when is_list(cs_id),
    do: if(service["country_service_id"] in cs_id, do: service, else: false)

  def filter_service(service, cs_id),
    do: if(service["country_service_id"] == cs_id, do: service, else: false)

  def make_completed_cost(input, fields, type, cs_id, working_time, cost_key) do
    #    common for all 3 service_types
    if type in ["walk_in", "on_demand", "home_service"] do
      service_price =
        if is_list(cs_id) do
          Enum.filter(fields["services_estimates"]["#{type}"], fn service ->
            if service["country_service_id"] in cs_id, do: service, else: false
          end)
        else
          Enum.filter(fields["services_estimates"]["#{type}"], fn service ->
            if service["country_service_id"] == cs_id, do: service, else: false
          end)
        end

      case fields["rate_type_for_#{type}"] do
        "Fixed Rate" ->
          case service_price do
            [] ->
              error(["Estimated Cost not found in settings against the Service"])

            [%{"final_amount" => cost}] ->
              input |> put(String.to_existing_atom("#{cost_key}"), cost) |> ok()

            data when is_list(data) ->
              cost = Enum.map(data, & &1["final_amount"]) |> Enum.sum()
              input |> put(String.to_existing_atom("#{cost_key}"), cost) |> ok()

            _ ->
              error(["Multiple records found in settings against provided data"])
          end

        "Hourly Rate" ->
          case service_price do
            [] ->
              {:error, ["Estimated Cost not found in settings against the Service"]}

            [%{"price_amount" => cost}] ->
              cost = round_off_value(cost * working_time)
              input |> put(String.to_existing_atom("#{cost_key}"), cost) |> ok()

            _ ->
              {:error, ["Multiple records found in settings against provided data"]}
          end

        _ ->
          {:error, ["Rate Type is not correct, only Fixed Rate or Hourly Rate allowed"]}
      end
    else
      error(["invalid service type"])
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @cost_error, __ENV__.line)
  end

  def get_settings_by(branch_id, slug) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: slug}) do
      nil ->
        error(["Service Rate settings doesn't exist!"])

      %{} = data ->
        data |> ok

      _ ->
        error(["unexpected error occurred!"])
    end
  end

  defp get_job_for_making_cost(id),
    do: Jobs.get_job(id) |> default_resp(msg: ["job doesn't exist"])

  def make_completed_job_cost(
        %{id: job_id, job_status_id: "completed", completed_at: completed_at} = params
      ) do
    with {:ok,
          %{
            employee_id: employee_id,
            service_type_id: service_type_id,
            started_working_at: started_working_at
          } = job}
         when started_working_at != nil <- get_job_for_making_cost(job_id),
         {:ok, data} <-
           fetch_branch_services(job),
         {:ok, %{id: branch_id}} <- JobController.get_branch_by_employee(employee_id),
         {:ok, %{fields: fields}} <- get_settings_by(branch_id, "service_cost_estimate") do
      working_hours = Timex.diff(completed_at, started_working_at, :seconds) / 3600

      cs_ids = get_country_service_ids(data)

      make_completed_cost(
        params,
        fields,
        service_type_id,
        cs_ids,
        working_hours,
        "cost_at_complete"
      )
      |> default_resp
    else
      {:error, err} ->
        error(err)

      exception ->
        logger(__MODULE__, exception, ["unable to make job cost"], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @cost_error, __ENV__.line)
  end

  def make_completed_job_cost(input), do: input |> ok

  def fetch_branch_services(job) do
    data =
      if is_nil(job.branch_service_ids) do
        JobController.get_branch_service(%{branch_service_id: job.branch_service_id})
      else
        JobController.get_branch_service(%{branch_service_ids: job.branch_service_ids})
      end

    case data do
      nil -> {:error, "No record found"}
      [] -> {:error, "No record found"}
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:ok, data}
    end
  end

  def get_country_service_ids(data) when is_nil(data), do: data

  def get_country_service_ids(data) do
    if is_list(data) do
      get(data, :country_service_id)
    else
      Map.get(data, :country_service_id)
    end
  end
end
