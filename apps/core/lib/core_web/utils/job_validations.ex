defmodule CoreWeb.Utils.JobValidations do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.{
    Settings,
    BSP
  }

  alias CoreWeb.Controllers.{SearchBSPController}
  alias CoreWeb.Helpers.{JobStatusesHelper}

  def check_auto_assign(_, %{branch_id: branch_id}), do: auto_assign(branch_id) |> ok()

  def auto_assign(branch_id) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "auto_schedule"}) do
      %{fields: %{"auto_schedule" => true}} -> true
      %{fields: %{"auto_schedule" => false}} -> false
      _ -> true
    end
  end

  @doc """
    validate_self_job_posting
    check bsp and job posting and prevent user to post job for self

   ##Examples
  ```elixir
    iex> validate_self_job_posting( required params )
    {:ok, employee} or {:error, "Some Error Message"}
  ```
  [Quick View Of This Function]
  -> prevent self job posting
  """

  def validate_self_job_posting(%{make_job: %{user_id: bsp_id}}, %{inserted_by: cmr_id})
      when bsp_id == cmr_id,
      do: error(["Job posting to Self is not allowed"])

  def validate_self_job_posting(%{make_job: %{user_id: _} = employee}, %{inserted_by: _}),
    do: employee |> ok

  def validate_self_job_posting(%{make_job: _}, _),
    do: error(["unable to verify self job posting"])

  def provider_availability_check(_, %{arrive_at: _at, expected_work_duration: ewd} = params) do
    if params[:is_flexible] do
      ["no need to check availability now"] |> ok
    else
      bsp = BSP.get_branch_by_search(params)
      bsp = Enum.map(bsp, &put(&1, :expected_work_duration, ewd))

      case SearchBSPController.filter_bsps_by_availability(bsp, params) do
        %{input: input, bsps: bsps} ->
          if bsps == [] do
            ["Selected Service Provider is not available right now, please search again!"]
            |> error
          else
            input |> ok
          end

        _ ->
          ["Something went wrong while searching Service Provider, please try again"] |> error
      end
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to determine Service Provider availability"],
        __ENV__.line
      )
  end

  def provider_availability_check(_, _params),
    do: ["something missing in params to check provider availability"] |> error

  @doc """
  validate_job/2
  Checks the starting, ending time and other params for requested job and validates it.

  -> TODO - validation compare maybe need to modify
  """

  def validate_job(
        %{
          make_job: %{
            employee_status_id: employee_status_id,
            contract_begin_date: contract_begin_date,
            contract_end_date: contract_end_date
          }
        },
        _
      ) do
    if employee_status_id != "active" do
      {:error, ["Employee status is" <> employee_status_id]}
    else
      current_time = DateTime.utc_now()

      if Timex.between?(current_time, contract_begin_date, contract_end_date, inclusive: :start) do
        {:ok, :valid_employee}
      else
        {:error, ["employee contract expired"]}
      end
    end
  end

  def verify_job_status(%{is_job_exist: job}, params) do
    case JobStatusesHelper.verify_job_status(job, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Error in verifying Job status"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to verify Job Status"], __ENV__.line)
  end

  #  defp verify_job_updating_timing(%{is_job_exist: %{arrive_at: arrive_at}}, params) do
  #    case params do
  #      %{job_status_id: "started_working"} -> job_updating_time(arrive_at)
  #      %{job_cmr_status_id: "on_board"} -> job_updating_time(arrive_at)
  #      %{job_bsp_status_id: "on_board"} -> job_updating_time(arrive_at)
  #      _ -> {:ok, params}
  #    end
  #  rescue
  #    _all -> {:error, ["unable to verify job updating timing"]}
  #  end

  #  defp job_updating_time(arrive_at) do
  #    if DateTime.utc_now >= Timex.beginning_of_day(arrive_at) and
  #       DateTime.utc_now <= Timex.end_of_day(arrive_at) do
  #      {:ok, @valid}
  #    else
  #      {:error, ["Can't start work outside Consumer request time"]}
  #    end
  #  end

  def verify_provider_on_reschedule(%{is_job_exist: job}, params) do
    case JobStatusesHelper.verify_provider_on_reschedule(job, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Error in verifying Service Provider for rescheduling"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Unable to verify Service Provider for Rescheduling."],
        __ENV__.line
      )
  end

  def verify_rescheduling_job_statuses(%{is_job_exist: job}, params),
    do: {:ok, JobStatusesHelper.handle_job_status(job, params)}
end
