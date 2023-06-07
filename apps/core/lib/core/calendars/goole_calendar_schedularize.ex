defmodule Core.Calendars.GoogleCalendarSchedularize do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.GoogleCalenders
  alias CoreWeb.Utils.GoogleCalenderApiHandler
  alias CoreWeb.Utils.CommonFunctions
  alias Core.{Accounts, Employees, Settings}

  def update_cmr_scheduler_on_google_calender(
        %{job: job},
        %{waiting_arrive_at: _waiting_arrive_at, approve_time_request: true} = params
      ) do
    Task.start(fn ->
      update_cmr_event_on_google_calender(
        job,
        make_params_for_update(params)
      )
    end)
  end

  def update_cmr_scheduler_on_google_calender(%{job: job}, params) do
    Task.start(fn ->
      if Map.get(params, :job_status_id) == "cancelled" do
        delete_cmr_event_on_google_calender(job)
      else
        params = make_params_for_update(params)

        cond do
          params == %{} -> {:ok, "No, need to update Google calender"}
          true -> update_cmr_event_on_google_calender(job, params)
        end
      end
    end)
  end

  def update_cmr_scheduler_on_google_calender(_, _) do
    {:ok, "No Need to update cmr scheduler on google calender"}
  end

  def update_cmr_event_on_google_calender(%{inserted_by: user_id} = job, params) do
    %{refresh_token: refresh_token} = Accounts.get_user!(user_id)
    %{cmr_event_id: event_id} = GoogleCalenders.get_google_calender_by_job_id(job.id)

    update(job.arrive_at, job.expected_work_duration, refresh_token, event_id, params)
  end

  def delete_cmr_event_on_google_calender(%{inserted_by: user_id} = job) do
    %{refresh_token: refresh_token} = Accounts.get_user!(user_id)
    %{cmr_event_id: event_id} = GoogleCalenders.get_google_calender_by_job_id(job.id)

    delete(event_id, refresh_token)
  end

  def update_bsp_scheduler_on_google_calender(
        %{job: job},
        %{waiting_arrive_at: _waiting_arrive_at, approve_time_request: true} = params
      ) do
    Task.start(fn ->
      update_bsp_event_on_google_calender(
        job,
        make_params_for_update(params)
      )
    end)
  end

  def update_bsp_scheduler_on_google_calender(%{job: job}, params) do
    Task.start(fn ->
      if Map.get(params, :job_status_id) == "cancelled" do
        delete_bsp_event_on_google_calender(job)
      else
        params = make_params_for_update(params)

        cond do
          params == %{} -> {:ok, "No, need to update Google calender"}
          true -> update_bsp_event_on_google_calender(job, params)
        end
      end
    end)
  end

  def update_bsp_scheduler_on_google_calender(_, _) do
    {:ok, "No Need to update cmr scheduler on google calender"}
  end

  def update_bsp_event_on_google_calender(job, params) do
    %{bsp_event_id: event_id} = GoogleCalenders.get_google_calender_by_job_id(job.id)

    update(
      job.arrive_at,
      job.expected_work_duration,
      get_refresh_token_by_job(job),
      event_id,
      params
    )
  end

  def delete_bsp_event_on_google_calender(job) do
    %{bsp_event_id: event_id} = GoogleCalenders.get_google_calender_by_job_id(job.id)
    delete(event_id, get_refresh_token_by_job(job))
  end

  def make_params_for_update(params) do
    Enum.reduce(params, %{}, fn
      {:job_address, v}, acc -> Map.put(acc, "location", v)
      {:title, v}, acc -> Map.put(acc, "summary", v)
      {:description, v}, acc -> Map.put(acc, "description", v)
      _, acc -> acc
    end)
  end

  def get_refresh_token_by_job(job) do
    %{refresh_token: refresh_token} =
      job
      |> get(:employee_id)
      |> Employees.get_employee!()
      |> get(:user_id)
      |> Accounts.get_user!()

    refresh_token
  end

  def update(arrive_at, expected_work_duration, refresh_token, event_id, params) do
    case GoogleCalenderApiHandler.update_event_on_google_calender(
           %{
             "arrive_at" => arrive_at,
             "expected_work_duration" => expected_work_duration,
             "refresh_token" => refresh_token,
             "event_id" => event_id
           },
           params
         ) do
      {:ok, message} -> {:ok, message}
      {:error, error} -> {:ok, error}
    end
  end

  def delete(event_id, refresh_token) do
    case GoogleCalenderApiHandler.delete_event_on_google_calender(%{
           "refresh_token" => refresh_token,
           "event_id" => event_id
         }) do
      {:ok, message} -> {:ok, message}
      {:error, error} -> {:ok, error}
    end
  end

  def check_cmr_sync_settings(%{job: job}, params) do
    case Settings.get_cmr_settings_by_slug_and_user(%{
           user_id: params.user_id,
           slug: "sync_google_calender"
         }) do
      [] ->
        {:ok, false}

      data ->
        value =
          data
          |> List.first()
          |> Map.get(:fields)
          |> List.first()
          |> Map.get("sync_google_calender")

        if value == true do
          case GoogleCalenders.create_google_calender(%{job_id: job.id}) do
            {:ok, data} -> {:ok, data}
            _ -> {:ok, false}
          end
        else
          {:ok, false}
        end
    end
  end

  def create_cmr_scheduler_on_google_calender(
        %{job: job, check_cmr_sync_settings: %{id: _google_calender_id} = google_cal},
        params
      ) do
    {:ok,
     Task.async(fn ->
       %{
         refresh_token: refresh_token
       } = Accounts.get_user!(params.user_id)

       # params = make_params_for_google_calender(job, params, refresh_token, get_attendee_details_when_bsp(job))
       params = make_params_for_google_calender(job, refresh_token)

       cond do
         params == %{} ->
           {:ok, "No Need to scheduler event on google calender"}

         true ->
           case create_event_on_google_calender(params) do
             {:ok, %{event_id: event_id}} ->
               # GoogleCalenders.get_google_calender_by_job_id(id)
               GoogleCalenders.update_google_calender(google_cal, %{cmr_event_id: event_id})

             # GoogleCalenders.create_google_calender(%{cmr_event_id: event_id, job_id: job.id})

             resp ->
               resp
           end
       end
     end)}
  end

  def create_cmr_scheduler_on_google_calender(_, _), do: {:ok, "Something went wrong"}

  def check_bsp_sync_settings(%{job: %{employee_id: nil}}, _), do: {:ok, false}

  def check_bsp_sync_settings(%{job: job}, _) do
    %{id: id} =
      job
      |> get(:employee_id)
      |> Employees.get_employee!()
      |> get(:user_id)
      |> Accounts.get_user!()

    case Settings.get_cmr_settings_by_slug_and_user(%{user_id: id, slug: "sync_google_calender"}) do
      [] ->
        {:ok, false}

      data ->
        value =
          data
          |> List.first()
          |> Map.get(:fields)
          |> List.first()
          |> Map.get("sync_google_calender")

        if value == true, do: {:ok, true}, else: {:ok, false}
    end
  end

  def create_bsp_scheduler_on_google_calender(
        %{
          check_bsp_sync_settings: true,
          check_cmr_sync_settings: %{id: _g_val_id} = google_cal,
          job: job
        },
        _params
      ) do
    Task.start(fn ->
      %{refresh_token: refresh_token} =
        job
        |> get(:employee_id)
        |> Employees.get_employee!()
        |> get(:user_id)
        |> Accounts.get_user!()

      # params = make_params_for_google_calender(job, params, refresh_token, get_attendee_details_when_cmr(params.user_id))
      params = make_params_for_google_calender(job, refresh_token)

      cond do
        params == %{} ->
          {:ok, "No Need to scheduler event on google calender"}

        true ->
          case create_event_on_google_calender(params) do
            {:ok, %{event_id: event_id}} ->
              # GoogleCalenders.get_google_calender_by_job_id(id)
              GoogleCalenders.update_google_calender(google_cal, %{bsp_event_id: event_id})

            resp ->
              resp
          end
      end
    end)
  end

  def create_bsp_scheduler_on_google_calender(_, _), do: {:ok, "Something went wrong"}

  def create_event_on_google_calender(params) do
    case GoogleCalenderApiHandler.create_event_on_google_calender(params) do
      {:ok, %{"id" => event_id}} -> {:ok, %{event_id: event_id}}
      # Core.GoogleCalenders.create_google_calender(%{cmr_event_id: event_id, job_id: job.id})
      {:ok, message} -> {:ok, message}
      {:error, message} -> {:ok, message}
    end
  end

  # def make_params_for_google_calender(job, params, refresh_token, attendee_detail) do
  def make_params_for_google_calender(job, refresh_token) do
    if is_nil(refresh_token) do
      %{}
    else
      case GoogleCalenderApiHandler.get_access_token_and_token_id(refresh_token) do
        {:ok, %{"access_token" => access_token, "id_token" => id_token}} ->
          {:ok, %{email: calender_id}} = Core.Google.user_info(id_token)

          %{
            arrive_at: job.arrive_at,
            expected_work_duration: job.expected_work_duration,
            job_title: job.title,
            job_description: job.description,
            location: job.job_address,
            calender_id: calender_id,
            # email: attendee_detail.email,
            # first_name: attendee_detail.first_name,
            # last_name: attendee_detail.last_name,
            access_token: access_token,
            time_zone: job.day_light
            # recurrence: check_occurrence(params)
          }
          |> merge_source_url(job.id)

        {:error, message} ->
          {:error, message}
      end
    end
  end

  def merge_source_url(params, job_id) do
    case CommonFunctions.generate_url("job/appointment", job_id |> to_string) do
      %{"error" => %{"message" => _message}} -> params
      url -> Map.put(params, :source, url)
    end
  end

  # def check_occurrence(params) do
  #   if Map.has_key?(params, :occurrence) do
  #     count = params[:occurrence][:re_occurrence] || 1

  #     cond do
  #       params[:occurrence][:repeat_unit] == :days -> "RRULE:FREQ=DAILY;COUNT=#{count}"
  #       params[:occurrence][:repeat_unit] == :weeks -> "RRULE:FREQ=WEEKLY;COUNT=#{count}"
  #       params[:occurrence][:repeat_unit] == :months -> "RRULE:FREQ=MONTHLY;COUNT=#{count}"
  #       params[:occurrence][:repeat_unit] == :years -> "RRULE:FREQ=YEARLY;COUNT=#{count}"
  #     end
  #   else
  #     "RRULE:FREQ=DAILY;COUNT=1"
  #   end
  # end

  def get_attendee_details_when_bsp(job) do
    %{
      refresh_token: refresh_token,
      email: email,
      profile: %{"first_name" => first_name, "last_name" => last_name}
    } =
      job
      |> get(:employee_id)
      |> Employees.get_employee!()
      |> get(:user_id)
      |> Accounts.get_user!()

    case GoogleCalenderApiHandler.get_access_token_and_token_id(refresh_token) do
      {:ok, %{"access_token" => _access_token, "id_token" => id_token}} ->
        {:ok, %{email: bsp_email}} = Core.Google.user_info(id_token)
        %{email: bsp_email, first_name: first_name, last_name: last_name}

      _ ->
        %{email: email, first_name: first_name, last_name: last_name}
    end
  end

  #   def get_attendee_details_when_cmr(user_id) do
  #     %{
  #         refresh_token: refresh_token,
  #         email: email,
  #         profile: %{"first_name" => first_name, "last_name" => last_name}
  #       } = Accounts.get_user!(user_id)

  #       case GoogleCalenderApiHandler.get_access_token_and_token_id(refresh_token) do
  #         {:ok, %{"access_token" => _access_token, "id_token" => id_token}} ->
  #           {:ok, %{email: bsp_email}} = Core.Google.user_info(id_token)
  #           %{email: bsp_email, first_name: first_name, last_name: last_name}
  #         _ -> %{email: email, first_name: first_name, last_name: last_name}
  #       end
  # end
end
