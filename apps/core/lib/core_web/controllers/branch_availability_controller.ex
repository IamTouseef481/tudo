defmodule CoreWeb.Controllers.BranchAvailabilityController do
  @moduledoc false
  use CoreWeb, :controller

  alias Core.Settings
  alias CoreWeb.Controllers.AvailabilityController
  alias CoreWeb.GraphQL.Resolvers.SearchBSPResolver
  alias CoreWeb.Utils.DateTimeFunctions, as: DT

  def get_branch_availability(input) do
    case Core.Jobs.get_branch_jobs_for_availability(input) do
      data ->
        data =
          Enum.map(data, fn job ->
            job_start = job.arrive_at
            job_end = DT.time_to_datetime(job.expected_work_duration, job_start)

            %{
              from: job_start,
              to: job_end
            }
          end)

        with {:ok, branch_availability} <- make_branch_availability(data, input),
             {:ok, branch_availability_slots} <- make_branch_availability_slots(data, input) do
          %{
            branch_id: input.branch_id,
            availability: branch_availability,
            availability_schedule: branch_availability_slots
          }
        else
          {:error, error} -> {:error, error}
          _ -> {:error, ["error while fetching branch availability"]}
        end
    end
  end

  def make_branch_availability(data, %{branch_id: branch_id} = input) do
    case Settings.get_settings_by(%{type: "branch", slug: ["availability"], branch_id: branch_id}) do
      [settings] ->
        availability =
          settings.fields |> keys_to_atoms() |> AvailabilityController.get_availability()

        availability_days = AvailabilityController.get_days()
        #        source_job_start = input.source_job.arrive_at
        #        source_job_start_local = DT.convert_utc_time_to_local_time(source_job_start)
        #
        #        source_job_end = DT.time_to_datetime(input.source_job.expected_work_duration, source_job_start)
        #        source_job_end_local = DT.convert_utc_time_to_local_time(source_job_end)
        holidays = AvailabilityController.get_holidays(input, availability_days)

        final_availability =
          Enum.reduce(availability_days, [], fn availability_day, acc ->
            jobs = AvailabilityController.get_jobs(data, availability_day)

            specific_holidays =
              Enum.reduce(holidays, [], fn holiday, acc ->
                if to_string(availability_day) in Map.keys(holiday) do
                  holiday["#{availability_day}"]
                else
                  acc
                end
              end)

            day = DT.day_name(availability_day)
            day_data = availability[DT.day_name(availability_day)]
            #        get a,b,c,d shifts from days

            if day_data == nil do
              availability_day = Date.to_string(availability_day)

              final_object_for_availability = %{
                schedule: [],
                schedule_meta: %{
                  date: availability_day,
                  day: day,
                  color: "red"
                }
              }

              [final_object_for_availability | acc]
            else
              jobs_breaks_shift =
                Enum.reduce(
                  Map.keys(day_data),
                  %{
                    schedule: [],
                    color: "green",
                    color_flag: true,
                    breaks_time: 0,
                    jobs_time: 0,
                    total_time: 0
                  },
                  fn shift, shifts_acc ->
                    shift = day_data[shift]
                    day_start = DT.time_to_datetime(shift.shift.from, availability_day)
                    day_end = DT.time_to_datetime(shift.shift.to, availability_day)
                    breaks = sort_list(shift.breaks, :from)
                    total_time = Timex.diff(day_end, day_start, :minutes)

                    shifts_acc =
                      Map.merge(shifts_acc, %{color_flag: true, total_time: total_time})

                    breaks =
                      Enum.reduce(breaks, shifts_acc, fn break, break_acc ->
                        break_start = DT.time_to_datetime(break.from, availability_day)
                        break_end = DT.time_to_datetime(break.to, availability_day)

                        AvailabilityController.consider_current_day_start(
                          break_acc,
                          day_start,
                          break_start,
                          break_end,
                          "break",
                          false
                        )
                      end)

                    #          -----------   holiday breaks latest one  --------------
                    breaks =
                      Enum.reduce(specific_holidays, breaks, fn holiday, break_acc ->
                        break_start = holiday.from
                        break_end = holiday.to
                        #                duration = Timex.diff(break_end, break_start, :minutes)

                        #            -----------     added later 1   --------------
                        #            {hours, minutes, seconds} = Time.to_erl(input.source_job.expected_work_duration)
                        #            total_seconds = (hours *3600)+ (minutes * 60) + seconds
                        #            break_start = Timex.shift(break_start, seconds: -total_seconds)

                        AvailabilityController.consider_current_day_start(
                          break_acc,
                          day_start,
                          break_start,
                          break_end,
                          "holiday",
                          false
                        )
                      end)

                    jobs_breaks =
                      Enum.reduce(jobs, breaks, fn job, job_acc ->
                        from =
                          DT.convert_utc_time_to_local_time(job.from)
                          |> Timex.shift(microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        to =
                          DT.convert_utc_time_to_local_time(job.to)
                          |> Timex.shift(microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        AvailabilityController.consider_current_day_start(
                          job_acc,
                          day_start,
                          from,
                          to,
                          "job",
                          false
                        )
                      end)

                    duration = Timex.diff(day_end, day_start, :minutes)

                    Map.merge(jobs_breaks, %{
                      day_shift: %{from: day_start, to: day_end, duration: duration}
                    })
                  end
                )

              availability_day = Date.to_string(availability_day)

              color =
                cond do
                  jobs_breaks_shift.total_time -
                    (jobs_breaks_shift.breaks_time + jobs_breaks_shift.jobs_time) < 120 ->
                    "red"

                  jobs_breaks_shift.breaks_time + jobs_breaks_shift.jobs_time >=
                      jobs_breaks_shift.total_time / 2 ->
                    "blue"

                  true ->
                    jobs_breaks_shift.color
                end

              final_object_for_availability =
                Map.merge(jobs_breaks_shift, %{
                  schedule_meta: %{
                    date: availability_day,
                    day: day,
                    day_shift: jobs_breaks_shift.day_shift,
                    color: color,
                    breaks_time: jobs_breaks_shift.breaks_time,
                    jobs_time: jobs_breaks_shift.jobs_time,
                    total_time: jobs_breaks_shift.total_time
                  }
                })

              final_object_for_availability =
                Map.drop(
                  final_object_for_availability,
                  [:color, :color_flag, :jobs_time, :total_time, :breaks_time, :day_shift]
                )

              [final_object_for_availability | acc]
            end
          end)

        {:ok, final_availability}

      [] ->
        {:error, ["availability settings for this branch doesn't exist"]}

      _ ->
        {:error, ["Error in retriving Availability Settings for this Branch"]}
    end
  end

  def make_branch_availability_slots(data, %{branch_id: branch_id} = input) do
    case Settings.get_settings_by(%{type: "branch", slug: ["availability"], branch_id: branch_id}) do
      [settings] ->
        availability =
          settings.fields |> keys_to_atoms() |> AvailabilityController.get_availability()

        availability_days = AvailabilityController.get_days()
        holidays = AvailabilityController.get_holidays(input, availability_days)

        final_availability =
          Enum.reduce(availability_days, [], fn availability_day, acc ->
            jobs = AvailabilityController.get_jobs(data, availability_day)

            specific_holidays =
              Enum.reduce(holidays, [], fn holiday, acc ->
                if to_string(availability_day) in Map.keys(holiday) do
                  holiday["#{availability_day}"]
                else
                  acc
                end
              end)

            day = DT.day_name(availability_day)
            day_data = availability[DT.day_name(availability_day)]
            #        get a,b,c,d shifts from days

            if day_data == nil do
              availability_day = Date.to_string(availability_day)

              final_object_for_availability = %{
                schedule: [],
                schedule_meta: %{
                  day: day,
                  color: "red",
                  date: availability_day
                }
              }

              [final_object_for_availability | acc]
            else
              jobs_breaks_shift =
                Enum.reduce(
                  Map.keys(day_data),
                  %{
                    schedule: [],
                    color: "green",
                    color_flag: true,
                    breaks_time: 0,
                    jobs_time: 0,
                    total_time: 0
                  },
                  fn shift, shifts_acc ->
                    shift = day_data[shift]

                    day_start =
                      if List.first(availability_days) == availability_day do
                        day_start =
                          DT.convert_utc_time_to_local_time(DateTime.utc_now())
                          |> SearchBSPResolver.adjust_time_slot()

                        #                day_start = ~U[2021-02-05 13:40:00.000000Z]
                        shift_start = DT.time_to_datetime(shift.shift.from, availability_day)

                        if DateTime.compare(day_start, shift_start) == :gt,
                          do: day_start,
                          else: shift_start
                      else
                        DT.time_to_datetime(shift.shift.from, availability_day)
                      end

                    day_end = DT.time_to_datetime(shift.shift.to, availability_day)
                    breaks = sort_list(shift.breaks, :from)
                    total_time = Timex.diff(day_end, day_start, :minutes)

                    shifts_acc =
                      Map.merge(shifts_acc, %{color_flag: true, total_time: total_time})

                    breaks =
                      Enum.reduce(breaks, shifts_acc, fn break, break_acc ->
                        break_start = DT.time_to_datetime(break.from, availability_day)
                        break_end = DT.time_to_datetime(break.to, availability_day)

                        #                break_slots = AvailabilityController.availability_slots_formation(break_start, break_end, "break")
                        AvailabilityController.consider_current_day_start(
                          break_acc,
                          day_start,
                          break_start,
                          break_end,
                          "break",
                          false
                        )
                      end)

                    #          -----------   holiday breaks latest one  --------------
                    breaks =
                      Enum.reduce(specific_holidays, breaks, fn holiday, break_acc ->
                        break_start = holiday.from
                        break_end = holiday.to

                        #            -----------     added later 1   --------------
                        #            {hours, minutes, seconds} = Time.to_erl(input.source_job.expected_work_duration)
                        #            total_seconds = (hours *3600)+ (minutes * 60) + seconds
                        #            break_start = Timex.shift(break_start, seconds: -total_seconds)
                        #            holiday_slots = AvailabilityController.availability_slots_formation(break_start, break_end, "break")

                        AvailabilityController.consider_current_day_start(
                          break_acc,
                          day_start,
                          break_start,
                          break_end,
                          "holiday",
                          false
                        )
                      end)

                    jobs_breaks =
                      Enum.reduce(jobs, breaks, fn job, job_acc ->
                        from =
                          DT.convert_utc_time_to_local_time(job.from)
                          |> Timex.shift(microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        to =
                          DT.convert_utc_time_to_local_time(job.to)
                          |> Timex.shift(microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        #                job_slots = AvailabilityController.availability_slots_formation(from, to, "job")

                        AvailabilityController.consider_current_day_start(
                          job_acc,
                          day_start,
                          from,
                          to,
                          "job",
                          false
                        )
                      end)

                    shift_duration = Timex.diff(day_end, day_start, :minutes)

                    day_shift = %{
                      from: day_start,
                      to: day_end,
                      shift_duration: shift_duration,
                      type: "shift"
                    }

                    #           -----------------------------------------------------------------------------------------
                    sorted_day_schedule =
                      Map.merge(
                        jobs_breaks,
                        %{schedule: Enum.sort_by(jobs_breaks.schedule, & &1.from)}
                      )

                    #              day_shift_slots = Enum.reduce(day_shifts, [], fn day_shift, day_shift_acc ->
                    #                day_shift_acc ++ AvailabilityController.availability_slots_formation(day_shift.from, day_shift.to, "available")
                    #              end)
                    #              total_slots = Enum.reduce(day_shift_slots, day_schedule, fn
                    #                %{from: shift_slot_start} = slot, slot_outer_acc ->
                    #                add_slot=Enum.reduce_while(break_slots, slot_outer_acc, fn %{from: break_slot_start}=_break_slot, _slot_acc ->
                    #                  if shift_slot_start == break_slot_start, do: {:halt, false}, else: {:cont, true}
                    #                end)
                    #                if add_slot do
                    #                  Map.merge(slot_outer_acc, %{schedule: slot_outer_acc.schedule ++ [slot]})
                    #                else
                    #                  slot_outer_acc
                    #                end
                    #              end)
                    break_slots =
                      Enum.reduce(sorted_day_schedule.schedule, [], fn %{type: type} = slot,
                                                                       break_slot_acc ->
                        if type in ["break", "job", "holiday"] do
                          break_slot_acc ++ [Map.merge(slot, %{from: slot.from, to: slot.to})]
                        else
                          break_slot_acc
                        end
                      end)

                    day_complete_schedule =
                      if break_slots == [] do
                        Map.merge(sorted_day_schedule, %{
                          schedule: [
                            %{
                              from: day_start,
                              to: day_end,
                              duration: shift_duration,
                              type: "available"
                            }
                          ],
                          day_shift: %{from: day_start, to: day_end, duration: shift_duration}
                        })
                      else
                        available_schedule =
                          Enum.reduce(break_slots, %{slot_start: day_shift.from, schedule: []}, fn
                            %{from: break_start, to: break_end}, break_collector ->
                              if break_collector.slot_start < break_start do
                                duration =
                                  Timex.diff(break_start, break_collector.slot_start, :minutes)

                                Map.merge(break_collector, %{
                                  slot_start: break_end,
                                  schedule:
                                    break_collector.schedule ++
                                      [
                                        %{
                                          from: break_collector.slot_start,
                                          to: break_start,
                                          duration: duration,
                                          type: "available"
                                        }
                                      ]
                                })
                              else
                                Map.merge(break_collector, %{slot_start: break_end})
                              end
                          end)

                        last_break_end = List.last(break_slots).to

                        available_schedule =
                          if last_break_end < day_shift.to do
                            duration = Timex.diff(day_shift.to, last_break_end, :minutes)

                            Map.merge(available_schedule, %{
                              schedule:
                                available_schedule.schedule ++
                                  [
                                    %{
                                      from: last_break_end,
                                      to: day_shift.to,
                                      duration: duration,
                                      type: "available"
                                    }
                                  ]
                            })
                          else
                            available_schedule
                          end

                        whole_day_schedule =
                          Map.merge(
                            sorted_day_schedule,
                            %{
                              schedule:
                                sorted_day_schedule.schedule ++ available_schedule.schedule
                            }
                          )

                        duration = Timex.diff(day_end, day_start, :minutes)

                        Map.merge(whole_day_schedule, %{
                          schedule: Enum.sort_by(whole_day_schedule.schedule, & &1.from),
                          day_shift: %{from: day_start, to: day_end, duration: duration}
                        })
                      end

                    #              checks if current local time is greater then today's shift end time then return [] schedule
                    if DateTime.compare(
                         day_start,
                         DT.time_to_datetime(shift.shift.to, availability_day)
                       ) == :lt do
                      day_complete_schedule
                    else
                      shifts_acc
                    end
                  end
                )

              if Map.has_key?(jobs_breaks_shift, :day_shift) do
                availability_day = Date.to_string(availability_day)

                color =
                  cond do
                    jobs_breaks_shift.total_time -
                      (jobs_breaks_shift.breaks_time + jobs_breaks_shift.jobs_time) < 120 ->
                      "red"

                    jobs_breaks_shift.breaks_time + jobs_breaks_shift.jobs_time >=
                        jobs_breaks_shift.total_time / 2 ->
                      "blue"

                    true ->
                      jobs_breaks_shift.color
                  end

                final_object_for_availability =
                  Map.merge(jobs_breaks_shift, %{
                    schedule_meta: %{
                      date: availability_day,
                      day: day,
                      day_shift: jobs_breaks_shift.day_shift,
                      color: color,
                      breaks_time: jobs_breaks_shift.breaks_time,
                      jobs_time: jobs_breaks_shift.jobs_time,
                      total_time: jobs_breaks_shift.total_time
                    }
                  })

                final_object_for_availability =
                  Map.drop(
                    final_object_for_availability,
                    [:color, :color_flag, :jobs_time, :total_time, :breaks_time, :day_shift]
                  )

                [final_object_for_availability | acc]
              else
                acc
              end
            end
          end)

        {:ok, final_availability}

      [] ->
        {:error, ["availability settings for this branch doesn't exist"]}

      _ ->
        {:error, ["Error in retriving Availability Settings for this Branch"]}
    end
  end
end
