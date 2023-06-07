defmodule CoreWeb.GraphQL.Resolvers.SearchBSPResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver

  alias CoreWeb.Controllers.{
    AvailabilityController,
    BranchAvailabilityController,
    SearchBSPController
  }

  alias CoreWeb.GraphQL.Resolvers.{BranchResolver, LeadResolver}
  alias Core.{BSP, Regions, Services}
  alias CoreWeb.Utils.CommonFunctions

  def list_businesses(_, _, _) do
    {:ok, BSP.list_businesses()}
  end

  def get_availability(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case Core.Jobs.get_job_id(input.job_id) do
      nil ->
        {:error, ["job doesn't exist"]}

      job ->
        input =
          Map.merge(input, %{
            inserted_by: current_user.id,
            employee_id: job.employee_id,
            source_job: job
          })

        case AvailabilityController.get_availability(input) do
          [] -> {:ok, []}
          {:error, error} -> {:error, error}
          data -> {:ok, data}
        end
    end
  end

  def get_branch_availability(
        _,
        %{input: %{branch_id: branch_id, country_service_id: cs_id} = input},
        _
      ) do
    case gets_branch_availability(input) do
      {:error, error} ->
        {:error, error}

      {:ok, data} ->
        case get_service_ewd(branch_id, cs_id) do
          {:error, error} ->
            {:error, error}

          {:ok, %{expected_work_duration: expected_work_duration}} ->
            {hours, minutes, seconds} = Time.to_erl(expected_work_duration)
            ewd_int = hours * 3600 + minutes * 60 + seconds

            {:ok,
             Map.merge(data, %{expected_work_duration: expected_work_duration, ewd_int: ewd_int})}
        end
    end
  end

  def get_branch_availability(_, %{input: input}, _) do
    gets_branch_availability(input)
  end

  def get_service_ewd(branch_id, country_service_id) do
    case Services.get_country_service(country_service_id) do
      nil ->
        {:error, ["Country Service doesn't exist!"]}

      %{service_id: service_id} ->
        case Services.get_service(service_id) do
          nil ->
            {:error, ["service doesn't exist!"]}

          %{service_type_id: type} ->
            case Core.Jobs.SettingsPicker.adds_ewd_in_params(branch_id, country_service_id, type) do
              duration when is_struct(duration) -> {:ok, %{expected_work_duration: duration}}
              {:error, error} -> {:error, error}
              _ -> {:error, "Expected Duration is not correct"}
            end
        end
    end
  end

  def gets_branch_availability(input) do
    case BSP.get_branch!(input.branch_id) do
      nil ->
        {:error, ["Business Branch doesn't exist!"]}

      %{} = branch ->
        case BranchAvailabilityController.get_branch_availability(input) do
          [] ->
            {:ok, []}

          {:error, error} ->
            {:error, error}

          data ->
            {:ok, Map.merge(data, add_geo(branch))}
        end
    end
  end

  def search_bsp(_, %{input: %{country_service_ids: cs_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    case Services.list_active_country_service_ids(cs_id) do
      [] ->
        {:error, ["These Services are not available in this Country"]}

      service_ids ->
        input = adjust_arrive_at_according_slot(input)

        case Regions.get_country_by_code(input.two_letter_country_code) do
          [] ->
            {:error, ["No record exist against your County"]}

          [%{id: country_id}] ->
            input =
              Map.merge(input, %{
                expected_work_duration: ~T[00:30:00],
                service_ids: service_ids,
                country_id: country_id,
                user_id: current_user.id
              })

            # will change service_id to service_ids list
            input =
              case LeadResolver.create_lead(input) do
                {:ok, lead_ids} ->
                  Map.merge(input, %{lead_ids: lead_ids})

                {:error, _} ->
                  input
              end

            case SearchBSPController.search_bsp(input) do
              {:error, error} ->
                {:error, error}

              data ->
                #                  data = %{data: data,
                #                    service_type_ids: get(data, :service_type_id) |> Enum.uniq()}
                {:ok, data}
            end

          _countries ->
            {:error, ["Error while retrieving Country from Country code"]}
        end
    end
  end

  def search_bsp(_, %{input: %{country_service_id: cs_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    # will change
    case Services.get_active_country_service(cs_id) do
      %{service_id: service_id} ->
        input = adjust_arrive_at_according_slot(input)

        case Regions.get_country_by_code(input.two_letter_country_code) do
          [] ->
            {:error, ["No record exist against your County"]}

          [%{id: country_id}] ->
            # will change for country_service_id
            input =
              Map.merge(input, %{
                expected_work_duration: ~T[00:30:00],
                service_id: service_id,
                country_id: country_id,
                user_id: current_user.id
              })

            # will change service_id to service_ids list
            input =
              case LeadResolver.create_lead(input) do
                {:ok, lead} -> Map.merge(input, %{lead_id: lead.id})
                {:error, _} -> input
              end

            case SearchBSPController.search_bsp(input) do
              {:error, error} -> {:error, error}
              data -> {:ok, data}
            end

          _countries ->
            {:error, ["Error while retriving Country from Country code"]}
        end

      _ ->
        {:error, ["This Service not available in this Country"]}
    end
  end

  def bsp_general_search(_, %{input: input}, _) do
    distance = get(input, :distance)

    input = if is_nil(distance), do: put(input, :distance, 30), else: input

    input =
      Map.merge(input, %{
        offset: ((input[:page_number] |> check_page_number || 1) - 1) * (input[:page_size] || 25),
        limit: input[:page_size] || 25
      })

    %{count: count, branches: branches} = Core.GeneralBsp.search(input)

    branches =
      Enum.map(branches, fn branch -> BranchResolver.add_custom_fields_to_branch(branch) end)
      |> Enum.map(&add_geo(&1))
      |> Enum.map(fn data ->
        distance = CommonFunctions.round_off_value(data[:distance])
        Map.merge(data, %{distance: distance})
      end)

    {:ok,
     %{
       branches: branches,
       page_number: input[:page_number] |> check_page_number || 1,
       page_size: input[:page_size] || 10,
       total_entries: check_count(count),
       total_pages: CommonFunctions.convert_float_to_next_integer(check_count(count), 25)
     }}
  end

  def check_count(count), do: if(count > 500, do: 500, else: count)

  def check_page_number(page_number), do: if(page_number > 20, do: 20, else: page_number)

  def adjust_arrive_at_according_slot(%{arrive_at: arrive_at} = input),
    do: input |> put(:arrive_at, adjust_time_slot(arrive_at))

  def adjust_time_slot(time) do
    case Timex.to_erl(time) do
      {{_, _, _}, {_, minutes, _}} ->
        diff =
          cond do
            minutes == 0 or minutes == 30 -> 0
            minutes > 0 and minutes < 15 -> -minutes
            (minutes >= 15 and minutes < 30) or (minutes > 30 and minutes < 45) -> 30 - minutes
            minutes >= 45 and minutes < 60 -> 60 - minutes
          end

        Timex.shift(time, minutes: diff)

      _ ->
        time
    end
  end
end
