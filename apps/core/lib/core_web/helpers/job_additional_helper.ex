defmodule CoreWeb.Helpers.JobAdditionalHelper do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.{
    Employees,
    Calendars,
    Leads,
    Services,
    Jobs,
    BSP,
    Accounts
  }

  alias Core.Schemas.{Calendar, Job}
  alias Core.Jobs.{JobHistoryHandler}

  @default_error ["unexpected error occurred"]
  @valid ["valid"]

  def make_bsp_calendar(%{job: %{employee_id: nil}}, _params), do: :assigning_off |> ok()

  def make_bsp_calendar(%{job: job}, _), do: Job.get_schedule(job) |> ok()

  def bsp_scheduler(%{make_bsp_calendar: :assigning_off}, _params), do: :not_added |> ok

  def bsp_scheduler(%{make_bsp_calendar: job}, _) do
    job
    |> get(:employee_id)
    |> Employees.get_employee!()
    |> get(:user_id)
    |> bsp_schedulers(job)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch user_id from employee_id"], __ENV__.line)
  end

  def bsp_scheduler(_, _), do: :not_applicable |> ok()

  defp bsp_schedulers(user_id, job) do
    case Calendars.get_calendar_by_user_id(user_id) do
      nil ->
        %{schedule: %{jobs: [job], tasks: [], events: []}, user_id: user_id}
        |> Calendars.create_calendar()

      %Calendar{} = data ->
        #        data = AtomicMap.convert(data, %{safe: false})
        schedule = Core.Calendars.Schedularize.make_schedule_for_calendar(data.schedule, job)
        Calendars.update_calendar(data, %{schedule: schedule})

      _ ->
        {:error, ["Something went wrong in scheduling"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def make_cmr_calendar(%{job: job}, _params), do: Job.get_schedule(job) |> ok

  def cmr_scheduler(%{make_cmr_calendar: job}, _) do
    job
    |> get(:inserted_by)
    |> cmr_schedulers(job)
  end

  defp cmr_schedulers(user_id, job) do
    case Calendars.get_calendar_by_user_id(user_id) do
      nil ->
        calendar = %{schedule: %{jobs: [job], tasks: [], events: []}, user_id: user_id}
        Calendars.create_calendar(calendar)

      %Calendar{} = data ->
        #        data = AtomicMap.convert(data, %{safe: false})
        schedule = Core.Calendars.Schedularize.make_schedule_for_calendar(data.schedule, job)
        Calendars.update_calendar(data, %{schedule: schedule})

      _ ->
        {:error, ["Something went wrong in scheduling"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def delete_leads(_, %{
        inserted_by: user_id,
        branch_service_id: bs_id,
        location_dest: location,
        arrive_at: arrive_at
      }) do
    leads_by = %{user_id: user_id, location: location, arrive_at: arrive_at}

    bs_id
    |> Services.get_branch_service()
    |> get(:country_service_id)
    |> then(fn cs_id -> put(leads_by, :country_service_id, cs_id) end)
    |> Leads.get_leads_by()
    |> Enum.map(&Leads.delete_lead(&1))
    |> ok
  rescue
    exception ->
      logger(__MODULE__, exception, ["Can't delete Leads, something went wrong"], __ENV__.line)
  end

  def delete_leads(_, %{
        inserted_by: user_id,
        branch_service_ids: ids,
        location_dest: location,
        arrive_at: arrive_at
      }) do
    leads_by = %{user_id: user_id, location: location, arrive_at: arrive_at}

    ids
    |> Services.get_branch_service()
    |> get(:country_service_id)
    |> get_leads_by(leads_by)
    |> Enum.map(&Leads.delete_lead(&1))
    |> ok
  rescue
    exception ->
      logger(__MODULE__, exception, ["Can't delete Leads, something went wrong"], __ENV__.line)
  end

  def get_leads_by(country_service_ids, leads_by) do
    Enum.reduce(country_service_ids, [], fn cs_id, acc ->
      leads_by
      |> put(:country_service_id, cs_id)
      |> Leads.get_leads_by()
      |> then(fn leads -> acc ++ leads end)
    end)
  end

  def auto_cancel_job_on_job_post(%{job: %{id: id, arrive_at: arrive_at} = job}, _) do
    {:ok, job_process_id} =
      Exq.enqueue_at(
        Exq,
        "default",
        #        Timex.shift(DateTime.utc_now, seconds: 30),
        Timex.shift(arrive_at, hours: 48),
        "CoreWeb.Workers.AutoCancelJobWorker",
        [id]
      )

    Jobs.update_job(job, %{auto_cancel_process_id: job_process_id})
    {:ok, @valid}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, @valid}
  end

  def auto_cancel_job_on_job_update(
        %{
          is_job_exist: %{
            id: id,
            arrive_at: arrive_at,
            waiting_arrive_at: waiting_arrive_at,
            auto_cancel_process_id: exq_job_id
          },
          job: job
        },
        %{approve_time_request: true}
      ) do
    #    delete previous job for cancel job, and add a new one
    #    Exq.Api.jobs(Exq.Api, "default")    #this fun is not giving exq scheduled jobs list
    #    Exq.Api.remove_job(Exq.Api, "default", exq_job_id) #this fun is not deleting job
    Exq.Api.remove_enqueued_jobs(Exq.Api, "default", exq_job_id)
    arrive_at = if is_nil(waiting_arrive_at), do: arrive_at, else: waiting_arrive_at

    {:ok, job_process_id} =
      Exq.enqueue_at(
        Exq,
        "default",
        #      Timex.shift(DateTime.utc_now, seconds: 30),
        Timex.shift(arrive_at, hours: 48),
        "CoreWeb.Workers.AutoCancelJobWorker",
        [id]
      )

    Jobs.update_job(job, %{auto_cancel_process_id: job_process_id})
    {:ok, @valid}
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, @valid}
  end

  def auto_cancel_job_on_job_update(_, _), do: {:ok, @valid}

  def create_job_history(%{job: job, rescheduling_statuses: params}, _),
    do: JobHistoryHandler.create_job_history(job, params) |> default_resp()

  def create_job_history(%{job: job}, params),
    do: JobHistoryHandler.create_job_history(job, params) |> default_resp()

  def update_branch_rating(%{job: %{branch_service_id: bs_id} = job}, %{cmr_to_bsp_rating: _}) do
    bs_ids = Map.get(job, :branch_service_ids) || [bs_id]

    case BSP.list_branches_by_branch_service(bs_ids) do
      [] ->
        {:ok, @valid}

      branches ->
        data =
          Enum.reduce(branches, [], fn %{id: id} = branch, acc ->
            avg_rating =
              Jobs.get_ratings_avg_by(%{branch_id: id})
              |> round_off_value(1)

            updated_params = %{
              rating: if(is_nil(avg_rating), do: 0.0, else: avg_rating)
            }

            case BSP.update_branch(branch, updated_params) do
              {:ok, data} -> [data | acc]
              {:error, _error} -> acc
            end
          end)

        if data == [], do: {:error, ["unable to update branch rating!"]}, else: {:ok, data}
    end
  end

  def update_branch_rating(_, _), do: {:ok, ["no need to update branch rating"]}

  def update_employee_rating(%{job: %{employee_id: emp_id}}, %{cmr_to_bsp_rating: _}) do
    case Employees.get_employee(emp_id) do
      nil ->
        {:ok, @valid}

      %{id: employee_id} = employee ->
        avg_rating =
          Jobs.get_ratings_avg_by(%{employee_id: employee_id})
          |> round_off_value(1)

        updated_params = %{rating: if(is_nil(avg_rating), do: 0.0, else: avg_rating)}

        case Employees.update_employee(employee, updated_params) do
          {:ok, data} -> {:ok, data}
          {:error, _error} -> {:error, ["unable to update branch rating!"]}
        end
    end
  end

  def update_employee_rating(_, _), do: {:ok, ["no need to update emoloyee rating"]}

  def update_cmr_rating(%{job: %{inserted_by: user_id}}, %{bsp_to_cmr_rating: _}) do
    case Accounts.get_user!(user_id) do
      nil ->
        {:ok, @valid}

      %{} = user ->
        avg_rating =
          Jobs.get_ratings_avg_by(%{user_id: user_id})
          |> round_off_value(1)

        updated_params = %{rating: if(is_nil(avg_rating), do: 0.0, else: avg_rating)}

        case Accounts.update_user(user, updated_params) do
          {:ok, data} -> {:ok, data}
          {:error, _error} -> {:error, ["unable to update user rating!"]}
        end
    end
  end

  def update_cmr_rating(_, _), do: {:ok, ["no need to update cmr rating"]}
end
