defmodule CoreWeb.Helpers.JobHelper do
  @moduledoc false
  use CoreWeb, :core_helper

  import CoreWeb.Endpoint, only: [broadcast: 3]
  import Absinthe.Subscription, only: [publish: 3]

  alias Core.{
    Bids,
    Employees,
    Invoices,
    Jobs,
    Services
  }

  alias Core.Jobs.{
    DashboardMetaHandler,
    JobNotificationHandler
  }

  alias Core.Schemas.{Employee, Job}
  alias CoreWeb.Controllers.{JobController}
  alias CoreWeb.Helpers.{ChatGroupHelper, JobAdditionalHelper}
  alias CoreWeb.Utils.{SocketHandler, JobValidations}
  alias Core.Calendars.GoogleCalendarSchedularize

  @valid ["valid"]
  @default_error ["unexpected error occurred"]
  @default_bsp_meta ["Unable to update Service Provider meta"]
  @default_cmr_meta ["Unable to update Consumer meta"]

  #######################################################
  ################### CREATE JOB SAGE ###################
  #######################################################
  def create_job(params) do
    new()
    #    |> run(:get_branch, &get_branch/2, &abort/3)
    |> run(:auto_assign, &JobValidations.check_auto_assign/2, &abort/3)
    |> run(:make_job, &make_job/2, &abort/3)
    |> run(:self_job_posting, &JobValidations.validate_self_job_posting/2, &abort/3)
    |> run(:availability_check, &JobValidations.provider_availability_check/2, &abort/3)
    |> run(:validate_job, &JobValidations.validate_job/2, &abort/3)
    |> run(:job, &create_job/2, &abort/3)
    |> run(:job_socket, &create_job_socket/2, &abort/3)
    |> run(:job_request, &update_job_request/2, &abort/3)
    |> run(:make_bsp_calendar, &JobAdditionalHelper.make_bsp_calendar/2, &abort/3)
    |> run(:make_cmr_calendar, &JobAdditionalHelper.make_cmr_calendar/2, &abort/3)
    |> run(:bsp_scheduler, &JobAdditionalHelper.bsp_scheduler/2, &abort/3)
    |> run(:cmr_scheduler, &JobAdditionalHelper.cmr_scheduler/2, &abort/3)
    |> run(
      :check_cmr_sync_settings,
      &GoogleCalendarSchedularize.check_cmr_sync_settings/2,
      &abort/3
    )
    |> run(
      :create_cmr_scheduler_on_google_calender,
      &GoogleCalendarSchedularize.create_cmr_scheduler_on_google_calender/2,
      &abort/3
    )
    |> run(
      :check_bsp_sync_settings,
      &GoogleCalendarSchedularize.check_bsp_sync_settings/2,
      &abort/3
    )
    |> run(
      :create_bsp_scheduler_on_google_calender,
      &GoogleCalendarSchedularize.create_bsp_scheduler_on_google_calender/2,
      &abort/3
    )
    |> run(:bidding_job, &update_bidding_job/2, &abort/3)
    |> run(:bidding_job_proposals, &reject_bidding_job_proposals/2, &abort/3)
    |> run(:update_bsp_meta, &update_bsp_meta/2, &abort/3)
    |> run(:update_cmr_meta, &update_cmr_meta/2, &abort/3)
    |> run(:delete_leads, &JobAdditionalHelper.delete_leads/2, &abort/3)
    |> run(:job_history, &JobAdditionalHelper.create_job_history/2, &abort/3)
    |> run(:auto_cancel_job, &JobAdditionalHelper.auto_cancel_job_on_job_post/2, &abort/3)
    |> run(:chat_data, &create_chat_group/2, &abort/3)
    |> run(:create_quotes, &create_quotes/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_job(params) do
    new()
    |> run(:is_job_exist, &is_job_exist/2, &abort/3)
    |> run(:verify_status, &JobValidations.verify_job_status/2, &abort/3)
    #    |> run(:updating_timing, &verify_job_updating_timing/2, &abort/3)
    |> run(:verify_provider, &JobValidations.verify_provider_on_reschedule/2, &abort/3)
    |> run(:rescheduling_statuses, &JobValidations.verify_rescheduling_job_statuses/2, &abort/3)
    |> run(:job, &update_job/2, &abort/3)
    |> run(:branch_rating, &JobAdditionalHelper.update_branch_rating/2, &abort/3)
    |> run(:employee_rating, &JobAdditionalHelper.update_employee_rating/2, &abort/3)
    |> run(:cmr_rating, &JobAdditionalHelper.update_cmr_rating/2, &abort/3)
    |> run(:job_socket, &update_job_socket/2, &abort/3)
    |> run(:make_bsp_calendar, &JobAdditionalHelper.make_bsp_calendar/2, &abort/3)
    |> run(:make_cmr_calendar, &JobAdditionalHelper.make_cmr_calendar/2, &abort/3)
    |> run(:bsp_scheduler, &JobAdditionalHelper.bsp_scheduler/2, &abort/3)
    |> run(:cmr_scheduler, &JobAdditionalHelper.cmr_scheduler/2, &abort/3)
    |> run(
      :update_cmr_scheduler_on_google_calender,
      &GoogleCalendarSchedularize.update_cmr_scheduler_on_google_calender/2,
      &abort/3
    )
    |> run(
      :update_bsp_scheduler_on_google_calender,
      &GoogleCalendarSchedularize.update_bsp_scheduler_on_google_calender/2,
      &abort/3
    )
    |> run(:update_bsp_meta, &update_bsp_job_meta/2, &abort/3)
    |> run(:update_cmr_meta, &update_cmr_job_meta/2, &abort/3)
    |> run(:job_history, &JobAdditionalHelper.create_job_history/2, &abort/3)
    |> run(:update_chat_group_status, &update_chat_group_status/2, &abort/3)
    |> run(:auto_cancel_job, &JobAdditionalHelper.auto_cancel_job_on_job_update/2, &abort/3)
    #    |> Exq.Api.remove_enqueued_jobs(Exq.Api, "default", exq_job_id)
    |> transaction(Core.Repo, params)
  end

  # ----------------------------------------------------------------------------

  # defp get_branch(_, params) do
  #   ids = params[:branch_service_ids] || params[:branch_service_id]

  #   Core.Services.get_branch_by_branch_service_id(ids)
  #   |> default_resp(msg: ["branch doesn't exist"])
  # rescue
  #   exception ->
  #     logger(__MODULE__, exception, ["enable to fetch branch"], __ENV__.line)
  # end

  @doc """
    make_job
    Get Employees by Branch Service id or ids and validate

   ##Examples
  ```elixir
    make_job(_, %{branch_service_id: id})
  ```
  [Quick View Of This Function]
  -> get the employees for branch_service_id and validate employees to make job
  -! Map and Reduce two enums and a case too complex, maybe simplify them?

  -> TODO - check employee availability and send correct employee.
  """

  def make_job(_, params) do
    case Services.get_employee_services_by_branch_service_id(params) do
      [] ->
        error(["employee_service doesn't exist"])

      employee_services ->
        employees = Enum.map(employee_services, &Employees.get_employee(&1.employee_id))

        employee =
          Enum.reduce(employees, [], fn employee, acc ->
            case validate_employee_for_make_job(employee) do
              %Employee{} = emp ->
                [emp | acc]

              {:error, _} ->
                acc

              _ ->
                error(["Error in validating Employee"])
            end
          end)

        case employee do
          [] ->
            error(["Employee doesn't exist, invalid status or contract expired!"])

          [employee | _] ->
            employee |> ok

          _ ->
            error(@default_error)
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch employee"], __ENV__.line)
  end

  defp validate_employee_for_make_job(%{employee_status_id: status_id})
       when status_id != "active",
       do: error(["Employee status is" <> status_id])

  defp validate_employee_for_make_job(
         %{
           employee_status_id: _,
           contract_begin_date: contract_begin_date,
           contract_end_date: contract_end_date
         } = employee
       ) do
    current_time = DateTime.utc_now()

    if Timex.between?(current_time, contract_begin_date, contract_end_date, inclusive: :start) do
      employee
    else
      error(["employee contract expired"])
    end
  end

  defp create_job(
         %{make_job: %{id: employee_id}, auto_assign: auto_assign},
         %{rest_gallery: rest_gallery} = params
       ) do
    params =
      if auto_assign do
        Map.merge(params, %{
          gallery: rest_gallery,
          employee_id: employee_id,
          job_status_id: "confirmed",
          job_bsp_status_id: "confirmed",
          job_cmr_status_id: "confirmed",
          confirmed_at: DateTime.utc_now()
        })
      else
        Map.merge(params, %{
          gallery: rest_gallery,
          job_status_id: "pending",
          job_bsp_status_id: "pending",
          job_cmr_status_id: "pending"
        })
      end

    params = extract_and_insert_type_ids(params)

    case Jobs.create_job(params) do
      {:ok, job} ->
        job |> preload_and_add_to_job()

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp create_job(
         %{make_job: %{id: employee_id}, auto_assign: auto_assign},
         %{gallery: gallery} = params
       ) do
    files = CoreWeb.Controllers.ImageController.upload(gallery, "services")

    params =
      if auto_assign do
        Map.merge(params, %{
          gallery: files,
          employee_id: employee_id,
          job_status_id: "confirmed",
          job_bsp_status_id: "confirmed",
          job_cmr_status_id: "confirmed",
          confirmed_at: DateTime.utc_now()
        })
      else
        Map.merge(params, %{
          gallery: files,
          job_status_id: "pending",
          job_bsp_status_id: "pending",
          job_cmr_status_id: "pending"
        })
      end

    params = extract_and_insert_type_ids(params)

    case Jobs.create_job(params) do
      {:ok, job} ->
        Exq.enqueue(Exq, "default", "CoreWeb.Workers.NotifyWorker", [:provider_approved, 1])
        job |> preload_and_add_to_job()

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp create_job(%{make_job: %{id: employee_id}, auto_assign: auto_assign}, params) do
    params =
      if auto_assign do
        Map.merge(params, %{
          employee_id: employee_id,
          job_status_id: "confirmed",
          job_bsp_status_id: "confirmed",
          job_cmr_status_id: "confirmed",
          confirmed_at: DateTime.utc_now()
        })
      else
        Map.merge(params, %{
          job_status_id: "pending",
          job_bsp_status_id: "pending",
          job_cmr_status_id: "pending"
        })
      end

    params = extract_and_insert_type_ids(params)

    case Jobs.create_job(params) do
      {:ok, job} ->
        job |> preload_and_add_to_job()

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp create_job(_, _), do: {:ok, :not_applicable}

  defp extract_and_insert_type_ids(%{service_type_ids: [type | _]} = params),
    do: params |> put(:service_type_id, type)

  defp extract_and_insert_type_ids(params), do: params

  @doc """
  preload_and_add_to_job
  this function preloads and adds followings to the job
  -> adds cmr and branches
  -> adds branch_services
  """
  def preload_and_add_to_job(job) do
    job
    |> JobController.preload_cmr_and_branch()
    |> add_branch_services_to_job()
    |> ok()
  end

  defp add_branch_services_to_job(%{branch_service_ids: nil} = job) do
    job
    |> get(:branch_service_id)
    |> Jobs.get_branch_services_for_bsp()
    |> add_location_to_branch_service()
    |> put_branch_services_to_job(job)
  end

  defp add_branch_services_to_job(job) do
    job
    |> get(:branch_service_ids)
    |> Jobs.get_branch_services_for_bsp()
    |> Enum.reduce([], fn b_s, acc ->
      if b_s.branch_service_id in job.branch_service_ids do
        b_s = add_location_to_branch_service(b_s)
        acc ++ [b_s]
      else
        acc
      end
    end)
    |> put_branch_services_to_job(job)
  end

  defp add_location_to_branch_service(bs_data) do
    bs_data
    |> get(:branch_location)
    |> then(fn %{coordinates: {long, lat}} ->
      put(bs_data, :branch_location, %{lat: lat, long: long})
    end)
  end

  defp put_branch_services_to_job(branch_services, job) when is_list(branch_services),
    do: put(job, :branch_service, branch_services)

  defp put_branch_services_to_job(branch_services, job),
    do: put(job, :branch_service, [branch_services])

  defp create_job_socket(%{job: %{inserted_by: cmr_id, employee_id: employee_id} = job}, _) do
    common_response_and_broadcast(job, true, employee_id, cmr_id)
  end

  defp update_job_request(_, %{job_request_id: job_request_id}) do
    case Jobs.get_job_request!(job_request_id) do
      nil ->
        ["Job Request Invalid"] |> error()

      %{lead_id: lead_id} = job_request ->
        case Jobs.update_job_request(job_request, %{job_status_id: "confirmed"}) do
          {:error, _} ->
            ["Unable to update job request"] |> error()

          {:ok, job_request} ->
            case Jobs.get_job_request_by(lead_id, "pending") do
              [] ->
                []

              job_requests ->
                Enum.each(job_requests, fn req ->
                  Jobs.update_job_request(req, %{job_status_id: "rejected"})
                end)
            end

            {:ok, job_request}
        end
    end
  end

  defp update_job_request(_, _), do: @valid |> ok

  defp update_bidding_job(_, %{bidding_proposal_id: bidding_proposal_id}) do
    with %{bidding_job_id: bidding_job_id} <- Bids.get_bid_proposal(bidding_proposal_id),
         %{} = bidding_job <- Bids.get_bidding_job(bidding_job_id),
         {:ok, bidding_job} <- Bids.update_bidding_job(bidding_job, %{accepted: true}) do
      {:ok, bidding_job}
    else
      nil ->
        ["Error in getting bidding job to be mark accept"] |> error()

      {:error, _} ->
        ["error in updating bidding job as accepted"] |> error()

      _ ->
        ["something went wrong"] |> error()
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Unable to update Bidding Job"]}
  end

  defp update_bidding_job(_, _), do: @valid |> ok()

  defp reject_bidding_job_proposals(%{bidding_job: %{id: bidding_job_id, title: job_title}}, %{
         bidding_proposal_id: bidding_proposal_id
       }) do
    notify_params = %{job_title: job_title, bid_id: bidding_job_id}

    with proposals <- Bids.get_bid_proposals_by(%{bid_id: bidding_job_id}),
         proposals <- Enum.reject(proposals, &(&1.id == bidding_proposal_id)) do
      updated_proposals =
        Enum.map(proposals, fn %{branch_id: branch_id} = proposal ->
          case Bids.update_bid_proposal(proposal, %{rejected_at: DateTime.utc_now()}) do
            {:ok, proposal} ->
              notify_params
              |> put(:branch_id, branch_id)
              |> JobNotificationHandler.send_notification_for_bsp("bid_reject_to_bsp")

              proposal

            {:error, _} ->
              proposal
          end
        end)

      {:ok, updated_proposals}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["Unable to update Bidding Job"]}
  end

  defp reject_bidding_job_proposals(_, _), do: [] |> ok()

  defp update_bsp_meta(%{job: %{employee_id: nil}}, _params), do: @valid |> ok()

  defp update_bsp_meta(
         %{
           job: %{employee_id: employee_id, service_type_id: service_type_id} = _job,
           bidding_job_proposals: proposals
         },
         %{branch_id: branch_id} = params
       )
       when employee_id != nil do
    case DashboardMetaHandler.update_bsp_meta(
           employee_id,
           branch_id,
           service_type_id,
           params[:bidding_proposal_id],
           proposals
         ) do
      {:ok, data} ->
        data |> ok()

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        @default_bsp_meta |> ok()
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      @default_bsp_meta |> ok()
  end

  defp update_cmr_meta(%{job: %{inserted_by: nil}}, _), do: @valid |> ok()

  defp update_cmr_meta(
         %{job: %{inserted_by: user_id} = job, bidding_job_proposals: proposals},
         %{branch_id: branch_id}
       ) do
    case DashboardMetaHandler.update_cmr_meta(
           user_id,
           branch_id,
           job,
           Enum.map(proposals, & &1.id)
         ) do
      {:ok, data} ->
        {:ok, data}

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        @default_cmr_meta |> ok()
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      @default_cmr_meta |> ok()
  end

  def create_chat_group(%{job: job}, _params) do
    case ChatGroupHelper.create_chat_group(job) do
      {:ok, _last, %{add_group_id_in_job: job}} ->
        {:ok, job}

      _ ->
        {:ok, job}
    end
  end

  def create_quotes(
        %{job: %{id: job_id}} = job,
        %{bidding_proposal_id: bidding_proposal_id, user_id: _user_id} = params
      ) do
    Task.start(fn ->
      case Core.Bids.get_bidding_proposal_quote_by(bidding_proposal_id) do
        nil ->
          create_quotes(job, Map.drop(params, [:bidding_proposal_id]))

        proposal_quote ->
          proposal_quote
          |> Map.from_struct()
          |> Map.drop([:__meta__, :bid_proposal, :bid_proposal_id, :business])
          |> Map.merge(%{job_id: job_id, reference_no: job_id})
          |> Core.Invoices.create_invoice()
      end
    end)
  end

  def create_quotes(%{job: %{id: job_id}}, %{user_id: user_id}) do
    Task.start(fn ->
      CoreWeb.GraphQL.Resolvers.InvoiceResolver.get_invoice_by_job(
        %{job_id: job_id},
        user_id
      )
    end)
  end

  # ----------------------------------------------------------------------------

  def is_job_exist(_, %{id: id, employee_id: employee_id} = _params) do
    case Jobs.get_job(id) do
      nil ->
        {:error, ["job doesn't exist"]}

      %Job{} = job ->
        case Employees.get_employee(employee_id) do
          nil -> {:error, ["New Employee record doesn't exist"]}
          %Employee{} -> {:ok, job}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def is_job_exist(_, %{id: id} = _params) do
    case Jobs.get_job(id) do
      nil -> {:error, ["job doesn't exist"]}
      %Job{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def is_job_exist(_, _) do
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  defp update_job(%{is_job_exist: job, rescheduling_statuses: updated_params}, %{
         rest_gallery: rest_gallery
       }) do
    params = Map.merge(updated_params, %{gallery: rest_gallery})
    params = check_job_status(job, params)

    case Jobs.update_job(job, params) do
      {:ok, data} ->
        preload_and_add_to_job(data)

      {:error, _} ->
        {:error, ["Something wrong in foreign key OR compulsory parameter is missing"]}

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp update_job(%{is_job_exist: job, rescheduling_statuses: updated_params}, %{gallery: gallery}) do
    files = CoreWeb.Controllers.ImageController.upload(gallery, "services")
    params = Map.merge(updated_params, %{gallery: files})
    params = check_job_status(job, params)

    case Jobs.update_job(job, params) do
      {:ok, data} ->
        preload_and_add_to_job(data)

      {:error, _} ->
        {:error, ["Something wrong in foreign key OR compulsory parameter is missing"]}

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp update_job(%{is_job_exist: job, rescheduling_statuses: updated_params}, _params) do
    params = check_job_status(job, updated_params)

    case Jobs.update_job(job, params) do
      {:ok, data} ->
        preload_and_add_to_job(data)

      {:error, _} ->
        {:error, ["Something wrong in foreign key OR compulsory parameter is missing"]}

      exception ->
        logger(__MODULE__, exception, :info, __ENV__.line)
        exception
    end
  end

  defp update_job(_, _), do: {:error, ["job params are not correct"]}

  defp check_job_status(%{inserted_by: inserted_by}, %{updated_by: updated_by} = params) do
    if updated_by == inserted_by do
      Map.merge(params, %{update_status_by: "cmr"})
    else
      Map.merge(params, %{update_status_by: "bsp"})
    end
  end

  #  if job_status_id is not in params
  defp check_job_status(_job, params), do: params

  def update_job_socket(%{job: %{inserted_by: cmr_id, employee_id: employee_id} = job}, _) do
    case Invoices.get_invoice_by_job_id(job.id) do
      [] ->
        Map.merge(job, %{invoice_id: nil, invoice_amount: nil})

      [%{id: invoice_id, final_amount: amount}] ->
        Map.merge(job, %{invoice_id: invoice_id, invoice_amount: amount})

      _ ->
        job
    end
    |> common_response_and_broadcast(false, employee_id, cmr_id)
  end

  def common_response_and_broadcast(job, created, employee_id, cmr_id) do
    if Map.has_key?(job, :branch) do
      branch_map = Map.drop(job.branch, [:search_tsvector])
      Map.put(job, :branch, branch_map)
    else
      job
    end
    |> put(:created, created)
    |> then(fn job -> publish(CoreWeb.Endpoint, job, job_socket: true) |> pass(job) end)
    |> SocketHandler.job_socket_processing()
    |> then(fn job -> snake_keys_to_camel(job) |> keys_to_atoms() end)
    |> then(fn job ->
      broadcast("job:user_id:#{cmr_id}", "job", %{job: job}) |> pass(job)
    end)
    |> then(fn job -> broadcast("job:employee_id:#{employee_id}", "job", %{job: job}) end)
    |> pass(job, with: :ok)
  end

  def update_bsp_job_meta(
        %{
          is_job_exist: %{job_bsp_status_id: previous_job_status},
          job: %{
            employee_id: employee_id,
            job_bsp_status_id: current_job_status,
            service_type_id: service_type_id
          }
        },
        _params
      ) do
    case DashboardMetaHandler.update_bsp_job_meta(
           previous_job_status,
           current_job_status,
           employee_id,
           service_type_id
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["can't update bsp meta"]}
  end

  def update_cmr_job_meta(
        %{
          is_job_exist: %{
            id: _id,
            job_cmr_status_id: previous_job_status,
            old_job_status_id: older_job_cmr_status
          },
          job: %{
            inserted_by: user_id,
            job_cmr_status_id: current_job_status,
            service_type_id: service_type_id
          }
        },
        _params
      ) do
    case DashboardMetaHandler.update_cmr_job_meta(
           previous_job_status,
           current_job_status,
           user_id,
           service_type_id,
           older_job_cmr_status
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["can't update cmr meta"]}
  end

  #  for invoice related jobs but currently it not used because invoices are updating this update job end point
  #  def send_notification_for_update_job(%{job: job}, params),
  #      do: JobNotificationHandler.send_notification_for_update_job(job, job, params)

  def update_chat_group_status(%{job: job}, params) do
    case ChatGroupHelper.update_chat_group_status(job, params) do
      {:ok, data} -> {:ok, data}
      {:error, :chat_group_not_updated} -> {:ok, job}
      _ -> {:ok, job}
    end
  end
end
