defmodule Core.Calendars.Schedularize do
  @moduledoc false
  use CoreWeb, :core_helper

  def make_schedule_for_calendar(schedule, %{job_status_id: job_status} = new_job) do
    schedule = keys_to_atoms(schedule)
    jobs = schedule.jobs

    sorted_jobs =
      if job_status in ["cancelled", "ignored", "finalized"] do
        remove_job_from_schedule(jobs, new_job)
      else
        update_job_from_schedule(jobs, new_job)
      end

    %{jobs: sorted_jobs, tasks: schedule.tasks, events: schedule.events}
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Error in marking schedule for calendar, try again"],
        __ENV__.line
      )
  end

  defp remove_job_from_schedule(jobs, new_job) do
    data =
      Enum.reduce(jobs, [], fn job, acc ->
        if job.id == new_job.id do
          acc
        else
          [job | acc]
        end
      end)

    Enum.sort_by(data, & &1.arrive_at)
  end

  #  adding new job in schedule and updating schedule on different job events/statuses
  defp update_job_from_schedule(jobs, new_job) do
    data =
      Enum.reduce(jobs, %{jobs: [], insert: true}, fn job, acc ->
        if job.id == new_job.id do
          Map.merge(acc, %{jobs: [new_job | acc.jobs], insert: false})
        else
          %{acc | jobs: [job | acc.jobs]}
        end
      end)

    if(data.insert, do: [new_job | data.jobs], else: data.jobs)
    |> Enum.sort_by(& &1.arrive_at)
  end

  #  commented as adding is handled in update function
  #  defp add_job_in_schedule(jobs, new_job) do
  #    insert = Enum.reduce_while(jobs, true, fn job, _acc ->
  #      if job.id == new_job.id do
  #        {:halt, false}
  #      else
  #        {:cont, true}
  #      end
  #    end)
  #
  #    data = if insert, do: [new_job | jobs], else: jobs
  #    Enum.sort_by(data, & &1.arrive_at)
  #  end

  #  def perform(schedule, new_job) do
  #    jobs = schedule.jobs
  #
  #    sorted_jobs = if length(jobs) >= 1 do
  #      data =
  #        Enum.reduce(jobs, %{jobs: [], insert: true}, fn job, acc ->
  #          if job.id == new_job.id do
  #            %{jobs: [new_job | acc[:jobs]], insert: false}
  #          else
  #            arrive_at = string_to_datetime(job.arrive_at)
  ##            expected_work_duration = Core.Utils.string_to_datetime(job.expected_work_duration)
  #            %{jobs: [Map.merge(job, %{arrive_at: arrive_at}) | acc[:jobs]], insert: acc[:insert]}
  ##            %{jobs: [Map.merge(job, %{arrive_at: arrive_at, expected_work_duration: expected_work_duration}) | acc[:jobs]], insert: acc[:insert]}
  ##            %{jobs: [job | acc[:jobs]], insert: acc[:insert]}
  #          end
  #        end)
  #
  #      data = if data.insert do
  #        [new_job | data.jobs]
  #      else
  #        data.jobs
  #      end
  #
  #      Enum.sort_by(data, fn x ->
  #        x.arrive_at
  #      end)
  #
  #    else
  #      [new_job]
  #    end
  #    schedule = %{jobs: sorted_jobs, tasks: schedule.tasks, events: schedule.events}
  #    schedule
  #  end
end
