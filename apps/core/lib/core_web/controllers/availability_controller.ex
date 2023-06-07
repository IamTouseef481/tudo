defmodule CoreWeb.Controllers.AvailabilityController do
  @moduledoc false
  use CoreWeb, :controller
  alias Core.Settings
  alias CoreWeb.GraphQL.Resolvers.SearchBSPResolver
  alias CoreWeb.Utils.DateTimeFunctions, as: DT

  def get_availability(%{custom: custom_availability, default: default_availability}) do
    if Map.keys(custom_availability) == [] do
      default_availability
    else
      custom_availability
    end
  end

  def get_availability(%{default: availability}), do: availability

  def get_availability(input) do
    case Core.Jobs.get_jobs_for_availability(input) do
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

        with {:ok, availability} <- make_availability(data, input),
             {:ok, availability_slots} <- make_availability_slots(data, input) do
          %{
            employee_id: input.employee_id,
            availability: availability,
            availability_schedule: availability_slots
          }
        else
          {:error, error} -> {:error, error}
          _ -> {:error, ["error while fetching branch availability"]}
        end
    end
  end

  def make_availability(data, input) do
    employee_id = input.employee_id

    case Settings.get_settings_by_employee_id(employee_id) do
      nil ->
        {:error, ["availability settings for this branch doesn't exist"]}

      %{} = settings ->
        availability = settings.fields |> keys_to_atoms |> get_availability
        availability_days = get_days()
        source_job_start = input.source_job.arrive_at
        source_job_start_local = DT.convert_utc_time_to_local_time(source_job_start)

        source_job_end =
          DT.time_to_datetime(input.source_job.expected_work_duration, source_job_start)

        source_job_end_local = DT.convert_utc_time_to_local_time(source_job_end)
        holidays = get_holidays(input, availability_days)

        final_availability =
          Enum.reduce(availability_days, [], fn availability_day, acc ->
            jobs = get_jobs(data, availability_day)

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
                date: availability_day,
                jobs: [],
                shift: %{},
                breaks: [],
                meta: %{
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
                    jobs: [],
                    shift: %{},
                    breaks: [],
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

                        #            -----------     added later 1   --------------
                        {hours, minutes, seconds} =
                          Time.to_erl(input.source_job.expected_work_duration)

                        total_seconds = hours * 3600 + minutes * 60 + seconds
                        break_start = Timex.shift(break_start, seconds: -total_seconds)

                        #                duration = Timex.diff(break_end, break_start, :minutes)
                        if (Timex.between?(
                              break_start,
                              source_job_start_local,
                              source_job_end_local
                            ) or
                              Timex.between?(
                                break_end,
                                source_job_start_local,
                                source_job_end_local
                              )) and break_acc.color_flag do
                          consider_current_day_start_in_breaks(
                            break_acc,
                            day_start,
                            break_start,
                            break_end,
                            true
                          )
                        else
                          consider_current_day_start_in_breaks(
                            break_acc,
                            day_start,
                            break_start,
                            break_end,
                            false
                          )
                        end
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

                        consider_current_day_start_in_breaks(
                          break_acc,
                          day_start,
                          break_start,
                          break_end,
                          false
                        )
                      end)

                    jobs_breaks =
                      Enum.reduce(jobs, breaks, fn job, job_acc ->
                        from =
                          Timex.shift(job.from, microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        to =
                          Timex.shift(job.to, microseconds: 1)
                          |> Timex.shift(microseconds: -1)

                        #                duration = Timex.diff(to, from, :minutes)
                        if (Timex.between?(job.from, source_job_start, source_job_end) or
                              Timex.between?(job.to, source_job_start, source_job_end)) and
                             job_acc.color_flag do
                          consider_current_day_start_in_jobs(job_acc, day_start, from, to, true)
                        else
                          consider_current_day_start_in_jobs(job_acc, day_start, from, to, true)
                        end
                      end)

                    duration = Timex.diff(day_end, day_start, :minutes)

                    Map.merge(jobs_breaks, %{
                      shift: %{from: day_start, to: day_end, duration: duration}
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

              jobs_breaks_shift = Map.drop(jobs_breaks_shift, [:color, :color_flag])

              final_object_for_availability =
                Map.merge(jobs_breaks_shift, %{
                  date: availability_day,
                  meta: %{
                    day: day,
                    color: color
                  }
                })

              [final_object_for_availability | acc]
            end
          end)

        {:ok, final_availability}
    end
  end

  def make_availability_slots(data, input) do
    employee_id = input.employee_id

    case Settings.get_settings_by_employee_id(employee_id) do
      nil ->
        {:error, ["availability settings for this branch doesn't exist"]}

      %{} = settings ->
        availability = settings.fields |> keys_to_atoms |> get_availability
        availability_days = get_days()
        source_job_start = input.source_job.arrive_at
        source_job_start_local = DT.convert_utc_time_to_local_time(source_job_start)

        source_job_end =
          DT.time_to_datetime(input.source_job.expected_work_duration, source_job_start)

        source_job_end_local = DT.convert_utc_time_to_local_time(source_job_end)
        holidays = get_holidays(input, availability_days)

        final_availability =
          Enum.reduce(availability_days, [], fn availability_day, acc ->
            jobs = get_jobs(data, availability_day)

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
                  date: availability_day,
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

                    day_start =
                      if List.first(availability_days) == availability_day do
                        day_start =
                          DT.convert_utc_time_to_local_time(DateTime.utc_now())
                          |> SearchBSPResolver.adjust_time_slot()

                        #                day_start = ~U[2021-02-05 13:00:00.000000Z]
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

                        #            -----------     added later 1   --------------
                        {hours, minutes, seconds} =
                          Time.to_erl(input.source_job.expected_work_duration)

                        total_seconds = hours * 3600 + minutes * 60 + seconds
                        extended_break_start = Timex.shift(break_start, seconds: -total_seconds)

                        #                duration = Timex.diff(break_end, break_start, :minutes)
                        if (Timex.between?(
                              extended_break_start,
                              source_job_start_local,
                              source_job_end_local
                            ) or
                              Timex.between?(
                                break_end,
                                source_job_start_local,
                                source_job_end_local
                              )) and break_acc.color_flag do
                          consider_current_day_start(
                            break_acc,
                            day_start,
                            break_start,
                            break_end,
                            "break",
                            true
                          )
                        else
                          consider_current_day_start(
                            break_acc,
                            day_start,
                            break_start,
                            break_end,
                            "break",
                            false
                          )
                        end
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

                        consider_current_day_start(
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

                        #                duration = Timex.diff(to, from, :minutes)
                        if (Timex.between?(job.from, source_job_start, source_job_end) or
                              Timex.between?(job.to, source_job_start, source_job_end)) and
                             job_acc.color_flag do
                          consider_current_day_start(job_acc, day_start, from, to, "job", true)
                        else
                          consider_current_day_start(job_acc, day_start, from, to, "job", false)
                        end
                      end)

                    #             ------------------------------------------------------
                    shift_duration = Timex.diff(day_end, day_start, :minutes)

                    day_shift = %{
                      from: day_start,
                      to: day_end,
                      duration: shift_duration,
                      type: "shift"
                    }

                    sorted_day_schedule =
                      Map.merge(
                        jobs_breaks,
                        %{schedule: Enum.sort_by(jobs_breaks.schedule, & &1.from)}
                      )

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
    end
  end

  def consider_current_day_start_in_breaks(break_acc, day_start, break_start, break_end, true) do
    cond do
      (DateTime.compare(day_start, break_start) == :gt and
         DateTime.compare(day_start, break_end) == :gt) or
          DateTime.compare(day_start, break_end) == :eq ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :lt ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          breaks:
            break_acc.breaks ++
              [%{from: day_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          breaks:
            break_acc.breaks ++
              [%{from: break_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })
    end
  end

  def consider_current_day_start_in_breaks(break_acc, day_start, break_start, break_end, false) do
    cond do
      (DateTime.compare(day_start, break_start) == :gt and
         DateTime.compare(day_start, break_end) == :gt) or
          DateTime.compare(day_start, break_end) == :eq ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :lt ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          breaks:
            break_acc.breaks ++
              [%{from: day_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          breaks:
            break_acc.breaks ++
              [%{from: break_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration
        })
    end
  end

  def consider_current_day_start_in_jobs(break_acc, day_start, break_start, break_end, true) do
    cond do
      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :gt ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) in [:lt, :eq] ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          jobs:
            break_acc.jobs ++
              [%{from: day_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          jobs:
            break_acc.jobs ++
              [%{from: break_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })
    end
  end

  def consider_current_day_start_in_jobs(break_acc, day_start, break_start, break_end, false) do
    cond do
      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :gt ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) in [:lt, :eq] ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          jobs:
            break_acc.jobs ++
              [%{from: day_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          jobs:
            break_acc.jobs ++
              [%{from: break_start, to: break_end, duration: duration, type: "break"}],
          breaks_time: break_acc.breaks_time + duration
        })
    end
  end

  def consider_current_day_start(break_acc, day_start, break_start, break_end, type, true) do
    cond do
      (DateTime.compare(day_start, break_start) == :gt and
         DateTime.compare(day_start, break_end) == :gt) or
          DateTime.compare(day_start, break_end) == :eq ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :lt ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          schedule:
            break_acc.schedule ++
              [%{from: day_start, to: break_end, duration: duration, type: type}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          schedule:
            break_acc.schedule ++
              [%{from: break_start, to: break_end, duration: duration, type: type}],
          breaks_time: break_acc.breaks_time + duration,
          color: "blue",
          color_flag: false
        })
    end
  end

  def consider_current_day_start(break_acc, day_start, break_start, break_end, type, false) do
    cond do
      (DateTime.compare(day_start, break_start) == :gt and
         DateTime.compare(day_start, break_end) == :gt) or
          DateTime.compare(day_start, break_end) == :eq ->
        break_acc

      DateTime.compare(day_start, break_start) == :gt and
          DateTime.compare(day_start, break_end) == :lt ->
        duration = Timex.diff(break_end, day_start, :minutes)

        Map.merge(break_acc, %{
          schedule:
            break_acc.schedule ++
              [%{from: day_start, to: break_end, duration: duration, type: type}],
          breaks_time: break_acc.breaks_time + duration
        })

      true ->
        duration = Timex.diff(break_end, break_start, :minutes)

        Map.merge(break_acc, %{
          schedule:
            break_acc.schedule ++
              [%{from: break_start, to: break_end, duration: duration, type: type}],
          breaks_time: break_acc.breaks_time + duration
        })
    end
  end

  def availability_slots_formation(sub_slot_start, major_slot_end, type, acc \\ []) do
    sub_slot_end = Timex.shift(sub_slot_start, minutes: 30)

    if sub_slot_end < major_slot_end do
      acc = acc ++ [%{from: sub_slot_start, to: sub_slot_end, type: type}]
      availability_slots_formation(sub_slot_end, major_slot_end, type, acc)
    else
      acc ++ [%{from: sub_slot_start, to: sub_slot_end, type: type}]
    end
  end

  def get_jobs(data, availability_day) do
    Enum.filter(data, fn job ->
      Timex.equal?(Timex.beginning_of_day(job.from), availability_day)
    end)
  end

  def get_days do
    current_date = Timex.today()
    current_datetime = Timex.beginning_of_day(Timex.now())

    last_date = Timex.add(current_date, Timex.Duration.from_weeks(2))
    rang = Date.range(current_date, last_date)
    count = Enum.count(rang) - 2

    dates =
      Enum.map(0..count, fn x ->
        Timex.add(current_datetime, Timex.Duration.from_days(x))
      end)

    #    List.replace_at(dates, 0, Timex.now)
    dates
  end

  def get_holidays(%{source_job: %{employee_id: employee_id}} = input, days) do
    holidays =
      case Core.Employees.get_employee(employee_id) do
        %{branch_id: branch_id} when branch_id != nil ->
          #        holidays = Core.OffDays.get_holiday_by(%{branch_id: branch_id, from: List.first(days), to: List.last(days)})
          Core.OffDays.get_holiday_by_branch(%{branch_id: branch_id})

        _ ->
          []
      end

    get_holidays(input, days, holidays)
  end

  def get_holidays(%{branch_id: branch_id} = input, days) do
    holidays = Core.OffDays.get_holiday_by_branch(%{branch_id: branch_id})
    get_holidays(input, days, holidays)
  end

  def get_holidays(_input, days, holidays) do
    final_holidays =
      Enum.reduce(days, [], fn day, day_acc ->
        single_day_holidays =
          Enum.reduce(holidays, %{"#{day}" => []}, fn holiday, holiday_acc ->
            cond do
              Timex.between?(holiday.from, day, Timex.end_of_day(day)) and
                  DateTime.compare(holiday.to, Timex.end_of_day(day)) == :lt ->
                %{"#{day}" => [%{from: holiday.from, to: holiday.to} | holiday_acc["#{day}"]]}

              Timex.between?(holiday.from, day, Timex.end_of_day(day)) and holiday.type == "multi" and
                  DateTime.compare(holiday.to, Timex.end_of_day(day)) == :gt ->
                %{"#{day}" => [%{from: day, to: Timex.end_of_day(day)} | holiday_acc["#{day}"]]}

              Timex.between?(holiday.from, day, Timex.end_of_day(day)) and
                  DateTime.compare(holiday.to, Timex.end_of_day(day)) == :gt ->
                %{
                  "#{day}" => [
                    %{from: holiday.from, to: Timex.end_of_day(day)} | holiday_acc["#{day}"]
                  ]
                }

              DateTime.compare(holiday.from, day) == :lt and
                  DateTime.compare(holiday.to, Timex.end_of_day(day)) == :gt ->
                %{"#{day}" => [%{from: day, to: Timex.end_of_day(day)} | holiday_acc["#{day}"]]}

              DateTime.compare(holiday.from, day) == :lt and holiday.type == "multi" and
                  Timex.between?(holiday.to, day, Timex.end_of_day(day)) ->
                %{"#{day}" => [%{from: day, to: Timex.end_of_day(day)} | holiday_acc["#{day}"]]}

              DateTime.compare(holiday.from, day) == :lt and
                  Timex.between?(holiday.to, day, Timex.end_of_day(day)) ->
                %{"#{day}" => [%{from: day, to: holiday.to} | holiday_acc["#{day}"]]}

              true ->
                %{"#{day}" => holiday_acc["#{day}"]}
            end
          end)

        [single_day_holidays | day_acc]
      end)

    final_holidays
  end
end
