defmodule CoreWeb.Controllers.SearchBSPController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Accounts, BSP, Employees, Jobs, PaypalPayments, Services, Settings}
  alias Core.Jobs.JobNotificationHandler, as: Notify
  alias Core.Jobs.SettingsPicker, as: Cost
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias CoreWeb.Controllers.{AvailabilityController, PromotionController}
  alias CoreWeb.Utils.DateTimeFunctions, as: DT
  alias CoreWeb.Utils.GoogleApiHandler, as: GH

  # New Function Clause
  def search_bsp(%{service_ids: _} = input) do
    bsps =
      BSP.get_branches_by_search(input)
      |> Enum.map(&add_geo(&1))

    case add_ewd_of_each_bsp(bsps, input) do
      {:error, error} ->
        {:error, error}

      [{:error, error} | _] ->
        {:error, error}

      bsps ->
        %{input: input, bsps: bsps} = filter_if_reoccurring(input, bsps)

        get_estimated_cost_and_valid_promotion(bsps, input)
        |> filter_employees(input)
    end
  end

  def search_bsp(%{arrive_at: _} = input) do
    bsps =
      BSP.get_branches_by_search(input)
      |> Enum.map(&add_geo(&1))

    case add_ewd_of_each_bsp(bsps, input) do
      {:error, error} ->
        {:error, error}

      [{:error, error} | _] ->
        {:error, error}

      bsps ->
        %{input: input, bsps: bsps} = filter_if_reoccurring(input, bsps)
        get_estimated_cost_and_valid_promotion(bsps, input) |> filter_employees(input)
    end
  end

  #  filter bsps when is_flexible true
  def filter_bsps_by_availability(bsps, %{is_flexible: true, arrive_at: arrive_at} = input) do
    case filter_bsps_by_availability_and_holidays(bsps, input) do
      [] ->
        arrive_at_slot_end = Timex.shift(arrive_at, hours: 2)
        arrive_at_slot_start = make_start_arrive_at_slot(arrive_at)

        add_in_arrive_at_to_recheck_availability(
          arrive_at,
          arrive_at_slot_start,
          arrive_at_slot_end,
          input,
          bsps
        )

      #        ----------------------old implementation---------------------------------
      #        new_arrive_at = Timex.shift(arrive_at, hours: 2)
      #        input = Map.merge(input, %{arrive_at: new_arrive_at})
      #        case filter_bsps_by_availability_and_holidays(bsps, input) do
      #          [] ->
      #            new_arrive_at = Timex.shift(arrive_at, hours: -2)
      #            input = Map.merge(input, %{arrive_at: new_arrive_at})
      #            bsps = filter_bsps_by_availability_and_holidays(bsps, input)
      #            %{input: input, bsps: bsps}
      #          bsps ->
      #            %{input: input, bsps: bsps}
      #        end
      bsps ->
        %{input: input, bsps: bsps}
    end
  end

  #  filter bsps when is_flexible false
  def filter_bsps_by_availability(bsps, input) do
    local_arrive_at = DT.convert_utc_time_to_local_time(input.arrive_at)
    updated_input = Map.merge(input, %{arrive_at: local_arrive_at})

    bsps =
      check_blocking_future_jobs(bsps)
      |> check_holiday(input)
      |> filter_by_availability(updated_input)
      |> filter_by_jobs(input)
      |> verify_bsp_appointment_usage(input)

    %{input: input, bsps: bsps}
  end

  def filter_bsps_by_availability_and_holidays(bsps, input) do
    local_arrive_at = DT.convert_utc_time_to_local_time(input.arrive_at)
    updated_input = Map.merge(input, %{arrive_at: local_arrive_at})

    check_blocking_future_jobs(bsps)
    |> check_holiday(input)
    |> filter_by_availability(updated_input)
    |> filter_by_jobs(input)
    |> verify_bsp_appointment_usage(input)
  end

  #   For multiple cs_ids
  def add_ewd_of_each_bsp(bsps, %{country_service_ids: cs_ids} = input) do
    case Services.list_services_by_country_service(cs_ids) do
      [] ->
        {:error, ["These Services are not available in this Country"]}

      _ ->
        {bsps, _} =
          Enum.map_reduce(bsps, ~T[00:00:00], fn %{
                                                   branch_id: branch_id,
                                                   branch_service_ids: branch_service_ids
                                                 } = bsp,
                                                 acc ->
            case Services.list_service_type_ids_and_country_service_ids(branch_service_ids) do
              [] ->
                {bsp, acc}

              branch_services ->
                ewd = Cost.adds_ewd_in_params(bsp, branch_id, branch_services, input)
                bsp = Map.merge(bsp, %{expected_work_duration: ewd})
                {bsp, ewd}
            end
          end)

        bsps
    end
  end

  # function will change due to change in country_service_ids
  def add_ewd_of_each_bsp(bsps, %{country_service_id: cs_id} = input) do
    # query will change for cs_ids
    # if arrive_at is same we have to sum the ewd of all services
    case Services.get_service_by_country_service(cs_id) do
      %{service_type_id: "on_demand" = type} ->
        Enum.map(bsps, &Map.merge(&1, %{service_type_id: type}))
        |> calculate_and_add_ewd_for_on_demand(input)

      %{service_type_id: service_type} ->
        Enum.map(bsps, fn %{branch_id: branch_id} = bsp ->
          ewd = Cost.adds_ewd_in_params(branch_id, cs_id, service_type)
          Map.merge(bsp, %{expected_work_duration: ewd})
        end)

      _ ->
        {:error, ["This Service not available in this Country"]}
    end
  end

  # for now we will send it for 1 on_demand only maybe will change for multiple pick&drop times
  def calculate_and_add_ewd_for_on_demand(bsps, input) do
    Enum.map(bsps, fn bsp ->
      calculate_ewd_for_on_demand(bsp, input)
    end)
  end

  def calculate_ewd_for_on_demand(
        %{location: %{coordinates: {origin_long, origin_lat}}} = bsp,
        %{location: %{lat: dest_lat, long: dest_long}} = input
      ) do
    coordinates_map =
      case input do
        %{location_src: %{lat: src_lat, long: src_long}} ->
          %{
            origin_lat: origin_lat,
            origin_long: origin_long,
            dest_lat: dest_lat,
            dest_long: dest_long,
            src_lat: src_lat,
            src_long: src_long
          }

        _ ->
          %{
            origin_lat: origin_lat,
            origin_long: origin_long,
            dest_lat: dest_lat,
            dest_long: dest_long
          }
      end

    case GH.distance_api(coordinates_map) do
      {:ok,
       [
         %{
           "elements" => [
             %{
               "duration" => %{"value" => pick_time_in_seconds} = pick_duration,
               "distance" => pick_distance
             }
             | _
           ]
         },
         %{
           "elements" => [
             _
             | [
                 %{
                   "duration" => %{"value" => drop_time_in_seconds} = drop_duration,
                   "distance" => drop_distance
                 }
               ]
           ]
         }
         | _
       ]} ->
        pick_time =
          CoreWeb.Utils.DateTimeFunctions.convert_seconds_to_time_string(pick_time_in_seconds)
          |> Time.from_iso8601!()

        drop_time =
          CoreWeb.Utils.DateTimeFunctions.convert_seconds_to_time_string(drop_time_in_seconds)
          |> Time.from_iso8601!()

        # service_type_id: ""} i think this will change too for []
        Map.merge(
          bsp,
          %{
            estimated_pick_time: pick_duration,
            estimated_drop_time: drop_duration,
            pick_distance: pick_distance,
            drop_distance: drop_distance,
            pick_expected_work_duration: pick_time,
            expected_work_duration: drop_time,
            service_type_id: ""
          }
        )

      {:ok,
       [
         %{
           "elements" => [
             %{"duration" => %{"value" => time_in_seconds}, "distance" => drop_distance} | _
           ]
         }
         | _
       ]} ->
        drop_time =
          CoreWeb.Utils.DateTimeFunctions.convert_seconds_to_time_string(time_in_seconds)
          |> Time.from_iso8601!()

        Map.merge(
          bsp,
          %{
            estimated_drop_time: drop_time,
            drop_distance: drop_distance,
            expected_work_duration: drop_time
          }
        )

      {:error, error} ->
        {:error, error}

      _ ->
        bsp
    end
  end

  def filter_by_jobs(bsps, %{arrive_at: upcoming_job_arrive_at} = input) do
    bsps =
      Enum.reduce(bsps, [], fn bsp, bsp_acc ->
        ewd =
          case bsp do
            %{expected_work_duration: expected_work_duration} -> expected_work_duration
            _ -> input.expected_work_duration
          end

        provider =
          if bsp.scheduled_jobs["jobs"] == [] do
            [bsp]
          else
            scheduled_jobs = get_scheduled_jobs_for_bsp(bsp)

            if scheduled_jobs == [] do
              [bsp]
            else
              Enum.reduce_while(scheduled_jobs, [], fn job, _acc ->
                %{arrive_at: scheduled_job_arrive_at, expected_work_duration: scheduled_job_ewd} =
                  job

                #            ---- -------     considering e_w_d in job_start   --------------
                {hours, minutes, seconds} = Time.to_erl(ewd)
                total_seconds = hours * 3600 + minutes * 60 + seconds

                scheduled_job_start_time =
                  Timex.shift(scheduled_job_arrive_at, seconds: -total_seconds)

                scheduled_job_end_time =
                  DT.time_to_datetime(scheduled_job_ewd, scheduled_job_arrive_at)

                if Timex.between?(
                     upcoming_job_arrive_at,
                     scheduled_job_start_time,
                     scheduled_job_end_time
                   ) do
                  {:halt, []}
                else
                  {:cont, [bsp]}
                end
              end)
            end
          end

        bsp_acc ++ provider
      end)

    bsps
  rescue
    _ ->
      bsps
  end

  def get_scheduled_jobs_for_bsp(bsp) do
    Enum.reduce(bsp.scheduled_jobs["jobs"], [], fn job, job_acc ->
      case DateTime.from_iso8601(job["arrive_at"]) do
        {:ok, arrive_at, _} ->
          case keys_to_atoms(job) do
            %{job_status_id: "confirmed"} = job ->
              [Map.merge(job, %{arrive_at: arrive_at}) | job_acc]

            _ ->
              job_acc
          end

        _ ->
          case Jobs.get_job(job["id"]) do
            %{job_status_id: "confirmed"} = job -> [job | job_acc]
            _ -> job_acc
          end
      end
    end)
  end

  def get_estimated_cost_and_valid_promotion(
        bsps,
        %{user_id: cmr_id, country_service_ids: cs_ids} = input
      ) do
    service_ids =
      case Services.list_services_ids_by_cs_ids(cs_ids) do
        [] -> nil
        services -> services
      end

    bsps =
      Enum.map(bsps, fn %{branch_service_ids: branch_service_ids, branch_id: branch_id} = bsp ->
        business_id = bsp.business_id

        bsp =
          case Services.list_service_type_ids_by_branch_service(branch_service_ids) do
            [] ->
              bsp

            # will change add + the costs for all services
            service_type_ids ->
              bsp =
                Map.merge(bsp, %{service_type_ids: service_type_ids, country_service_ids: cs_ids})

              case Cost.make_job_cost(bsp) do
                {:ok, bsp} -> bsp
                _ -> bsp
              end
          end

        input =
          Map.merge(input, %{
            service_ids: service_ids,
            business_id: business_id,
            cmr_id: cmr_id,
            branch_id: branch_id,
            discountable_price: bsp[:cost],
            job_time: bsp[:arrive_at]
          })

        promotions =
          PromotionController.get_promotions_by(input)
          |> PromotionController.add_branch_in_deals()

        Map.merge(bsp, %{promotions: promotions})
      end)

    bsps
  end

  # get_estimated_cost_and_valid_promotion will change
  def get_estimated_cost_and_valid_promotion(
        bsps,
        %{user_id: cmr_id, country_service_id: cs_id} = input
      ) do
    # get_country_service will change
    service_id =
      case Services.get_country_service(cs_id) do
        %{service_id: service_id} -> service_id
        _ -> nil
      end

    Enum.map(bsps, fn %{branch_service_id: branch_service_id, branch_id: branch_id} = bsp ->
      business_id =
        case BSP.get_branch!(branch_id) do
          %{business_id: business_id} -> business_id
          _ -> nil
        end

      bsp =
        case Services.get_branch_service(branch_service_id) do
          %{service_type_id: service_type_id} ->
            # will change add + the costs for all services
            case Cost.make_job_cost(
                   Map.merge(bsp, %{service_type_id: service_type_id, country_service_id: cs_id})
                 ) do
              {:ok, bsp} -> bsp
              _ -> bsp
            end

          _ ->
            bsp
        end

      input =
        Map.merge(input, %{
          service_id: service_id,
          business_id: business_id,
          cmr_id: cmr_id,
          branch_id: branch_id,
          discountable_price: bsp[:cost],
          job_time: bsp[:arrive_at]
        })

      promotions =
        PromotionController.get_promotions_by(input)
        |> PromotionController.add_branch_in_deals()

      Map.merge(bsp, %{promotions: promotions})
    end)
  end

  #    check holidays function with is_flexible
  #  def check_holiday(%{arrive_at: arrive_at, is_flexible: is_flexible} = input, bsps) do
  #    Enum.reduce(bsps, [], fn bsp, bsp_acc ->
  #      holidays = Core.OffDays.get_holiday_by_branch(%{branch_id: bsp.branch_id})
  #      case holidays do
  #         [] -> bsps
  #          _ ->
  #            bsp_check = Enum.reduce_while(holidays, [], fn holiday, acc ->
  ##            -----------     considering e_w_d in holiday_start   --------------
  #              {hours, minutes, seconds} = Time.to_erl(input.expected_work_duration)
  #              total_seconds = (hours *3600)+ (minutes * 60) + seconds
  #              holiday_start = Timex.shift(holiday.from, seconds: -total_seconds)
  #              cond do
  #                Timex.between?(arrive_at, holiday_start, holiday.to) -> {:halt, []}
  #                Timex.between?(arrive_at, holiday_start, holiday.to) == false -> {:cont, [bsp]}
  #              end
  #
  ##              if is_flexible do
  ##                cond do
  ##                  Timex.between?(arrive_at, holiday_start, holiday.to) and holiday.type == "multi" ->
  ##                    {:halt, []}
  ##                  Timex.between?(arrive_at, holiday_start, holiday.to) ->
  ##                    cond do
  ##                      Timex.between?(Timex.shift(arrive_at, hours: 2), holiday_start, holiday.to)
  ##                      and Timex.between?(Timex.shift(arrive_at, hours: -2), holiday_start, holiday.to) ->
  ##                        {:halt, []}
  ##                      true -> {:cont, [bsp]}
  ##                    end
  ##                  Timex.between?(arrive_at, holiday_start, holiday.to) == false -> {:cont, [bsp]}
  ##                end
  ##              else
  ##                cond do
  ##                  Timex.between?(arrive_at, holiday_start, holiday.to) -> {:halt, []}
  ##                  Timex.between?(arrive_at, holiday_start, holiday.to) == false -> {:cont, [bsp]}
  ##                end
  ##              end
  #            end)
  #            a=if bsp_check == [] do
  #              bsp_acc
  #            else
  #              bsp_check ++  bsp_acc
  #            end
  #            a
  #      end
  #    end)
  #  end

  #    check holidays function
  def check_holiday(bsps, %{arrive_at: arrive_at} = input) do
    Enum.reduce(bsps, [], fn bsp, bsp_acc ->
      expected_work_duration =
        case bsp do
          %{expected_work_duration: expected_work_duration} -> expected_work_duration
          _ -> input.expected_work_duration
        end

      bsp = Map.merge(bsp, %{arrive_at: arrive_at})
      holidays = Core.OffDays.get_holiday_by_branch(%{branch_id: bsp.branch_id})

      if holidays == [] do
        [bsp | bsp_acc]
      else
        bsp_check =
          Enum.reduce_while(holidays, [], fn holiday, _acc ->
            #            -----------     considering e_w_d in holiday_start   --------------
            {hours, minutes, seconds} = Time.to_erl(expected_work_duration)
            total_seconds = hours * 3600 + minutes * 60 + seconds
            holiday_start = Timex.shift(holiday.from, seconds: -total_seconds)

            if holiday.type == "multi" do
              cond do
                Timex.between?(
                  arrive_at,
                  Timex.beginning_of_day(holiday_start),
                  Timex.end_of_day(holiday.to)
                ) ->
                  {:halt, []}

                true ->
                  {:cont, [bsp]}
              end
            else
              cond do
                Timex.between?(arrive_at, holiday_start, holiday.to) -> {:halt, []}
                true -> {:cont, [bsp]}
              end
            end
          end)

        if bsp_check == [], do: bsp_acc, else: bsp_acc ++ bsp_check
      end
    end)
  end

  def filter_by_availability([], _b), do: []

  def filter_by_availability(bsps, %{arrive_at: arrive_at} = input) do
    #    arrive_at= ~U[2019-07-08 19:37:28Z]

    a =
      Enum.reduce(bsps, %{data: [], branches: [], added: true}, fn
        %{availability: availability} = bsp, acc ->
          expected_work_duration =
            case bsp do
              %{expected_work_duration: expected_work_duration} -> expected_work_duration
              _ -> input.expected_work_duration
            end

          availability =
            availability |> keys_to_atoms() |> AvailabilityController.get_availability()

          acc = Map.merge(acc, %{added: true})
          day = availability[DT.day_name(arrive_at)]
          #        get a,b,c,d shifts from days
          acc =
            if day != nil do
              Enum.reduce(Map.keys(day), acc, fn shift, shifts_acc ->
                shift = day[shift]

                day_start =
                  DT.time_to_datetime(shift.shift.from, Timex.beginning_of_day(arrive_at))

                day_end = DT.time_to_datetime(shift.shift.to, Timex.beginning_of_day(arrive_at))

                #            -----------  considering e_w_d in day_shift_end  --------------
                {hours, minutes, seconds} = Time.to_erl(expected_work_duration)
                total_seconds = hours * 3600 + minutes * 60 + seconds
                day_end = Timex.shift(day_end, seconds: -total_seconds)

                if Timex.between?(arrive_at, day_start, day_end, inclusive: true) and
                     shifts_acc.added and bsp.branch_id not in shifts_acc.data do
                  shift_acc =
                    Enum.reduce(shift.breaks, shifts_acc, fn break, break_acc ->
                      break_start =
                        DT.time_to_datetime(break.from, Timex.beginning_of_day(arrive_at))

                      break_end = DT.time_to_datetime(break.to, Timex.beginning_of_day(arrive_at))

                      #            -----------     considering e_w_d in break_start   --------------
                      {hours, minutes, seconds} = Time.to_erl(expected_work_duration)
                      total_seconds = hours * 3600 + minutes * 60 + seconds
                      break_start = Timex.shift(break_start, seconds: -total_seconds)

                      if Timex.between?(arrive_at, break_start, break_end) do
                        Map.merge(break_acc, %{added: false})
                      else
                        break_acc
                      end
                    end)

                  shift_acc =
                    if shift_acc.added do
                      data = [bsp.branch_id | shift_acc.data]
                      branches = [bsp | shift_acc.branches]
                      Map.merge(shift_acc, %{data: data, branches: branches})
                    else
                      shift_acc
                    end

                  shift_acc
                else
                  shifts_acc
                end
              end)
            else
              acc
            end

          acc
      end)

    a.branches
  end

  def check_blocking_future_jobs(bsps) do
    Enum.reduce(bsps, [], fn %{branch_id: branch_id} = bsp, acc ->
      case Settings.get_settings_by(%{branch_id: branch_id, slug: "block_future_jobs"}) do
        %{fields: %{"on_hold" => false}} -> [bsp | acc]
        _ -> acc
      end
    end)
  end

  defp filter_employees(bsps, params) do
    bsps =
      Enum.reduce(bsps, [], fn bsp, acc ->
        case check_employees_of_bsp(bsp, params) do
          [] -> acc
          [bsp] -> [bsp | acc]
          _ -> acc
        end
      end)

    bsps
  rescue
    _ ->
      bsps
  end

  #  skip that function and  call next when country_service_id is taken from input
  #  defp check_employees_of_bsp(bsp, %{country_id: country_id, service_id: service_id} = params) do
  #    case Services.get_country_service_by_country_and_service_id(
  #           %{country_id: country_id, service_id: service_id}) do
  #      [] -> []
  #      [cs] -> get_branch_service(bsp, Map.merge(params, %{country_service_id: cs.id}))
  #      _ -> []
  #    end
  #  end

  defp check_employees_of_bsp(
         %{branch_id: branch_id} = bsp,
         %{country_service_id: cs_id} = params
       ) do
    case Services.get_branch_services_by_branch_id(branch_id, cs_id) do
      [] -> []
      [bs] -> validate_employees(bsp, Map.merge(params, %{branch_service_id: bs.id}))
      _ -> []
    end
  end

  @doc """
  validate_employees/2

  Validate Employees.

  TODO - check employee availability and send correct employee.
  """

  def validate_employees(bsp, params) do
    case Services.get_employee_services_by_branch_service_id(params) do
      [] ->
        []

      employee_services ->
        employees = Enum.map(employee_services, &Employees.get_employee(&1.employee_id))

        employee =
          Enum.reduce(employees, [], fn employee, emp_acc ->
            case validate_employee_for_make_job(employee) do
              [] -> emp_acc
              [emp] -> [emp | emp_acc]
              _ -> emp_acc
            end
          end)

        case employee do
          [] ->
            []

          employees ->
            {employees, _} =
              employees
              |> Enum.sort_by(& &1.rating, :desc)
              |> Enum.split(3)

            Enum.each(
              employees,
              fn emp ->
                bsp =
                  Map.merge(bsp, %{
                    employee_id: emp.id,
                    employee_current_location: emp.current_location
                  })

                case bsp do
                  %{service_type_id: "on_demand"} -> send_request(bsp, params)
                  _ -> %{}
                end
              end
            )

            [bsp]
        end
    end
  end

  defp validate_employee_for_make_job(
         %{
           employee_status_id: employee_status_id,
           contract_begin_date: contract_begin_date,
           contract_end_date: contract_end_date
         } = employee
       ) do
    if employee_status_id != "active" do
      []
    else
      current_time = DateTime.utc_now()

      if Timex.between?(current_time, contract_begin_date, contract_end_date, inclusive: :start) do
        [employee]
      else
        []
      end
    end
  end

  defp make_start_arrive_at_slot(arrive_at) do
    start_arrive_at_slot = Timex.shift(arrive_at, hours: -2)

    case DateTime.compare(start_arrive_at_slot, DateTime.utc_now()) do
      :gt -> start_arrive_at_slot
      _ -> DateTime.utc_now()
    end
  end

  defp add_in_arrive_at_to_recheck_availability(
         arrive_at,
         arrive_at_slot_start,
         arrive_at_slot_end,
         input,
         bsps
       ) do
    new_arrive_at = Timex.shift(arrive_at, minutes: 30)

    if new_arrive_at >= arrive_at_slot_start and new_arrive_at <= arrive_at_slot_end do
      input = Map.merge(input, %{arrive_at: new_arrive_at})

      case filter_bsps_by_availability_and_holidays(bsps, input) do
        [] ->
          add_in_arrive_at_to_recheck_availability(
            new_arrive_at,
            arrive_at_slot_start,
            arrive_at_slot_end,
            input,
            bsps
          )

        bsps ->
          %{input: input, bsps: bsps}
      end
    else
      subtract_in_arrive_at_to_recheck_availability(
        arrive_at,
        arrive_at_slot_start,
        arrive_at_slot_end,
        input,
        bsps
      )
    end
  end

  #  on job post
  defp verify_bsp_appointment_usage(
         bsps,
         %{branch_service_id: _, service_type_id: service_type_id} = _input
       ) do
    Enum.filter(bsps, fn %{branch_id: branch_id} ->
      case BSP.get_branch!(branch_id) do
        nil ->
          {:error, ["branch doesn't exist"]}

        %{business_id: business_id} ->
          case PaypalPayments.get_paypal_subscription_by_business(business_id) do
            [] ->
              {:error, ["Bid Proposal can't Created. Please Upgrade Your Plan"]}

            [%{annual: annual} = subscription | _] ->
              key = "bsp_#{service_type_id}_appointments" |> String.to_atom()
              feature = Map.get(subscription, key)

              case Common.updated_subscription_usage(
                     subscription,
                     annual,
                     Map.put(%{}, key, feature)
                   ) do
                {:error, _} -> false
                {:ok, _} -> true
              end
          end
      end
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  #  on bsp search
  # verify_bsp_appointment_usage will change for cs_ids
  defp verify_bsp_appointment_usage(bsps, %{country_service_id: country_service_id} = _input) do
    Enum.filter(bsps, fn %{branch_id: branch_id} ->
      # get_service_by_country_service will change for cs_ids
      %{service_type_id: id} = Services.get_service_by_country_service(country_service_id)

      case BSP.get_branch!(branch_id) do
        nil ->
          {:error, ["branch doesn't exist"]}

        %{business_id: business_id} ->
          case PaypalPayments.get_paypal_subscription_by_business(business_id) do
            [] ->
              {:error, [id <> " service not available. Please Upgrade Your Plan"]}

            [%{annual: annual} = subscription | _] ->
              # make multiple maps and will change for each service_id
              key = "bsp_#{id}_appointments" |> String.to_atom()
              feature = Map.get(subscription, key)

              case Common.updated_subscription_usage(
                     subscription,
                     annual,
                     Map.put(%{}, key, feature),
                     false
                   ) do
                {:error, _} -> false
                {:ok, _} -> true
              end
          end
      end
    end)
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  #  on reschedule job, no check because no new job is created to be verified from subscription limit
  defp verify_bsp_appointment_usage(bsps, _), do: bsps

  defp subtract_in_arrive_at_to_recheck_availability(
         arrive_at,
         arrive_at_slot_start,
         arrive_at_slot_end,
         input,
         bsps
       ) do
    new_arrive_at = Timex.shift(arrive_at, minutes: -30)

    if new_arrive_at >= arrive_at_slot_start and new_arrive_at <= arrive_at_slot_end do
      input = Map.merge(input, %{arrive_at: new_arrive_at})

      case filter_bsps_by_availability_and_holidays(bsps, input) do
        [] ->
          subtract_in_arrive_at_to_recheck_availability(
            new_arrive_at,
            arrive_at_slot_start,
            arrive_at_slot_end,
            input,
            bsps
          )

        bsps ->
          %{input: input, bsps: bsps}
      end
    else
      %{input: input, bsps: []}
    end
  end

  defp send_request(bsp, input) do
    input = convert_locations_to_geo(bsp, input)

    %{
      title: bsp.service_name,
      cost: bsp.cost,
      arrive_at: input[:arrive_at],
      expected_work_duration: bsp.expected_work_duration,
      bsp_current_location: bsp.employee_current_location,
      location_dest: input[:location_dest],
      location_src: input[:location_src],
      cmr_id: input[:user_id],
      lead_id: input[:lead_id],
      job_status_id: "pending",
      employee_id: bsp.employee_id,
      branch_service_id: bsp.branch_service_id
    }
    |> Jobs.create_job_request()
    |> case do
      {:error, _} ->
        {:error, ["unable to create job request"]}

      {:ok, %{title: title}} ->
        case Accounts.get_user_by_employee_id(bsp.employee_id) do
          nil ->
            {:ok, ["Valid"]}

          %{id: user_id, email: email} ->
            Notify.sends_notification(
              user_id,
              "bsp",
              %{branch_id: bsp.branch_id},
              "job_request_to_bsp_on_demand"
            )

            {:ok, _email_job_id} =
              Exq.enqueue(
                Exq,
                "default",
                "CoreWeb.Workers.NotificationEmailsWorker",
                [
                  "job_request_to_bsp_on_demand",
                  %{email: email, job_title: title, branch_id: bsp.branch_id},
                  "bsp"
                ]
              )
        end
    end
  end

  defp convert_locations_to_geo(bsp, input) do
    case input do
      %{location_src: location_src} = input ->
        Map.merge(input, %{
          location_dest: %Geo.Point{
            coordinates: {input.location.long, input.location.lat},
            srid: 4326
          },
          location_src: %Geo.Point{coordinates: {location_src.long, location_src.lat}, srid: 4326}
        })

      _ ->
        Map.merge(input, %{
          location_dest: %Geo.Point{
            coordinates: {input.location.long, input.location.lat},
            srid: 4326
          },
          location_src: bsp.branch_location
        })
    end
  end

  #  def add_calculated_bsp_rating(bsps) do
  #    Enum.map(bsps, fn %{branch_id: branch_id} = bsp ->
  #      avg_rating = Core.Jobs.get_ratings_avg_by(%{branch_id: branch_id})
  #                   |> CoreWeb.Utils.CommonFunctions.round_off_value(1)
  #      Map.merge(bsp, %{rating: (if is_nil(avg_rating), do: 0.0, else: avg_rating)})
  #    end)
  #  end

  defp filter_if_reoccurring(input, bsps) when not is_nil(input.occurrence) and bsps != [] do
    occurrence = input |> Map.get(:occurrence)
    repeat_every = occurrence |> Map.get(:repeat_every)
    arrive_at = input |> Map.get(:arrive_at)

    Enum.reduce_while(0..occurrence[:re_occurrence], %{}, fn
      0, acc ->
        {:cont, Map.merge(acc, filter_bsps_by_availability(bsps, input))}

      count, %{input: input, bsps: bsps} = acc ->
        shift_time_opts = %{occurrence[:repeat_unit] => count * repeat_every} |> Map.to_list()
        input = Map.merge(input, %{arrive_at: Timex.shift(arrive_at, shift_time_opts)})
        {:cont, Map.merge(acc, filter_bsps_by_availability(bsps, input))}
    end)
  end

  defp filter_if_reoccurring(input, bsps), do: filter_bsps_by_availability(bsps, input)
end
