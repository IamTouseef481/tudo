defmodule CoreWeb.GraphQL.Resolvers.JobResolver do
  @moduledoc false

  use CoreWeb.GraphQL, :resolver

  alias Core.{Accounts, BSP, Employees, Jobs, Services}
  alias Core.Jobs.SettingsPicker
  alias Core.Schemas.RandomTokens
  alias Core.Schemas.User
  alias CoreWeb.Controllers.JobController
  alias CoreWeb.Helpers.UserHelper, as: SendEmail
  alias CoreWeb.GraphQL.Resolvers.{BusinessResolver, UserResolver}

  @update_error ["you don't have permission to update this job"]

  def job_statuses(_, _, _) do
    {:ok, Jobs.list_job_statuses()}
  end

  def job_categories(_, _, _) do
    {:ok, Jobs.list_job_categories()}
  end

  def get_job_request_by(_, %{input: input}, _) do
    case Jobs.get_job_request_by(input) do
      [] -> {:error, ["No Job Requests Yet"]}
      job_requests -> {:ok, job_requests}
    end
  end

  def get_job_request(_, %{input: %{id: id}}, _) do
    case Jobs.get_job_request!(id) do
      nil -> {:error, ["Job request doesn't exist"]}
      job_request -> {:ok, job_request}
    end
  end

  def create_job_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.create_job_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_job_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.get_job_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_job_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.update_job_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_job_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.delete_job_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def create_job_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.create_job_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_job_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.get_job_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_job_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.update_job_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def delete_job_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case JobController.delete_job_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def get_jobs_for_cmr(_, %{input: input}, %{context: %{current_user: current_user}}) do
    final_jobs =
      if Map.has_key?(input, :branch_id) do
        Map.merge(input, %{branch_id: input.branch_id, user_id: current_user.id})
        |> Jobs.get_jobs_for_cmr_with_notes()
      else
        Map.merge(input, %{user_id: current_user.id})
        |> Jobs.get_jobs_for_cmr()
      end
      |> JobController.get_cmr_jobs()

    {
      :ok,
      final_jobs
      |> Enum.map(&location_src(&1))
      |> Enum.map(&location_dest(&1))
    }
  end

  def get_jobs_for_bsp(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{current_user_id: current_user.id})

    case JobController.get_bsp_jobs(input) do
      {:ok, jobs} ->
        {
          :ok,
          jobs
          |> Enum.map(&location_src(&1))
          |> Enum.map(&location_dest(&1))
        }

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["something went wrong"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["can't get jobs for bsp"], __ENV__.line)
  end

  def get_employee_jobs(_, %{input: %{branch_id: branch_id}}, %{
        context: %{current_user: current_user}
      }) do
    jobs =
      case Employees.get_employee_by_branch_id(current_user.id, branch_id) do
        [] ->
          {:error, ["employee doesn't exist!"]}

        [employee] ->
          JobController.get_employee_jobs(employee)

        exception ->
          logger(__MODULE__, exception, ["employee doesn't exists!"], __ENV__.line)
      end

    {
      :ok,
      jobs
      |> Enum.map(&location_src(&1))
      |> Enum.map(&location_dest(&1))
    }
  end

  def post_job_on_behalf(_, %{input: %{email: email} = input}, %{
        context: %{current_user: %{acl_role_id: roles} = current_user}
      }) do
    if Enum.member?(roles, "bsp") do
      case Accounts.get_user_by_email(email) do
        nil ->
          case UserResolver.create_straight_user(input) do
            {:error, error} ->
              {:error, error}

            {:ok, _last, %{user: %{id: cmr_id}}} ->
              post_job_on_behalf(%{input: input, user_id: current_user.id, cmr_id: cmr_id})

            # {:ok, %{meta_message: "user created and email sent!"}}
            _ ->
              {:error, ["unable to send request!"]}
          end

        %{status_id: "confirmed", id: cmr_id} ->
          post_job_on_behalf(%{input: input, user_id: current_user.id, cmr_id: cmr_id})

        user ->
          user_map = %{user: %User{email: email}}

          case SendEmail.generate_token(user_map, %{purpose: "registration_activation"}) do
            {:error, error} ->
              {:error, error}

            {:ok, %RandomTokens{} = generate_token} ->
              case SendEmail.send_email(%{generate_token: generate_token}, :noting) do
                {:error, error} ->
                  {:error, error}

                {:ok, _} ->
                  post_job_on_behalf(%{input: input, user_id: current_user.id, cmr_id: user.id})
                  # {:ok, %{meta_message: "email sent!"}}
              end

            _ ->
              {:error, ["email already sent!"]}
          end
      end
    else
      {:error, ["you don't have permission!"]}
    end
  end

  def post_job_on_behalf(_, _, _) do
    {:error, ["you don't have permission!"]}
  end

  def post_job_on_behalf(%{input: input, user_id: user_id, cmr_id: cmr_id}) do
    if Map.has_key?(input, :dynamic_fields) do
      Map.merge(input, %{
        user_id: user_id,
        inserted_by: cmr_id,
        dynamic_fields: string_to_map(input.dynamic_fields),
        on_behalf_cmr: true
      })
    else
      Map.merge(input, %{user_id: user_id, inserted_by: cmr_id, on_behalf_cmr: true})
    end
    |> process_locations
    |> JobController.post_job()
  end

  def post_job(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    if Map.has_key?(input, :will_pick_at) do
      date_time = DateTime.compare(input.will_pick_at, input.arrive_at)

      cond do
        date_time == :lt -> post_job(input, id)
        date_time == :gt -> {:error, "arrive_at should be greater than will_pick_at"}
        true -> {:error, "arrive_at should be greater than will_pick_at"}
      end
    else
      post_job(input, id)
    end
  end

  def post_job(input, id) do
    input =
      Map.merge(input, %{
        user_id: id,
        inserted_by: id,
        dynamic_fields: string_to_map(Map.get(input, :dynamic_fields))
      })

    input = input |> process_locations

    case post_job_if_reoccurring(input) do
      {:error, error} ->
        {:error, error}

      %{error: error} ->
        {:error, error}

      %{jobs: jobs} when is_list(jobs) ->
        jobs |> ok()

      %{jobs: job} ->
        job |> ok()

      {:ok, job} ->
        job |> ok()

      [job | _] = jobs when is_struct(job) ->
        jobs |> ok()

      exception ->
        logger(__MODULE__, exception, ["Something went wrong!!"], __ENV__.line)
    end
  end

  def validity_for_job(%{id: job_id, updated_by: current_user_id} = _input) do
    case Jobs.get_job(job_id) do
      nil ->
        {:error, ["job doesn't exist!"]}

      %{inserted_by: user_id, employee_id: employee_id} ->
        if employee_id != nil do
          if user_id == current_user_id or
               Employees.get_employee_by_user(%{
                 employee_id: employee_id,
                 user_id: current_user_id
               }) != nil do
            true
          else
            false
          end
        else
          if user_id == current_user_id, do: true, else: false
        end
    end
  end

  defp process_locations(input) do
    input =
      if Map.has_key?(input, :location_dest),
        do: get_and_merge(input, :location_dest),
        else: input

    if Map.has_key?(input, :location_src), do: get_and_merge(input, :location_src), else: input
  end

  defp get_and_merge(input, key),
    do: input |> put(key, %Geo.Point{coordinates: {input[key].long, input[key].lat}, srid: 4326})

  def update_job(_, %{input: %{dynamic_fields: dynamic_fields} = input}, %{
        context: %{current_user: current_user}
      }) do
    input =
      Map.merge(input, %{
        updated_by: current_user.id,
        dynamic_fields: string_to_map(dynamic_fields)
      })

    if validity_for_job(input),
      do: input |> process_locations |> JobController.update_job(),
      else: error(@update_error)
  end

  def update_job(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{updated_by: current_user.id})

    if validity_for_job(input),
      do: input |> process_locations |> JobController.update_job(),
      else: error(@update_error)
  end

  def revise_job_estimate(_, %{input: %{job_id: job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{id: job_id, updated_by: current_user.id})

    if validity_for_job(input) do
      case Jobs.get_job(job_id) do
        %{} = job -> Jobs.update_job(job, %{revise_cost: input.revise_cost, id: job_id})
        _ -> {:error, ["Error while fetching the Job"]}
      end
    else
      {:error, ["You don't have permission to update Estimated Cost"]}
    end
  end

  def make_job_estimate(_, %{input: %{job_id: job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if validity_for_job(Map.merge(input, %{id: job_id, updated_by: current_user.id})) do
      case Jobs.get_job(job_id) do
        %{branch_service_id: bs_id, revise_cost: revise_cost} ->
          if revise_cost do
            makes_job_estimate(input, bs_id, revise_cost)
          else
            {:error, ["no request to update cost estimates"]}
          end

        _ ->
          {:error, ["Error while fetching the Job"]}
      end
    else
      {:error, ["You don't have permission to update Estimated Cost"]}
    end
  end

  def update_job_estimate(_, %{input: %{job_id: job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{id: job_id, updated_by: current_user.id})

    if validity_for_job(input) do
      case Jobs.get_job(job_id) do
        %{} = job -> Jobs.update_job(job, %{cost: input.cost, revise_cost: false})
        _ -> {:error, ["Error while fetching the Job"]}
      end
    else
      {:error, ["You don't have permission to update Estimated Cost"]}
    end
  end

  def makes_job_estimate(
        %{job_id: job_id, fixed_rate: fixed_rate, cost: cost} = _input,
        bs_id,
        revise_cost
      ) do
    if fixed_rate do
      {:ok, %{cost: cost, id: job_id, revise_cost: revise_cost}}
    else
      with %{branch_id: _} = bs_data <- Services.get_branch_service(bs_id),
           {:ok, %{expected_work_duration: ewd}} <- SettingsPicker.add_ewd_in_params(bs_data) do
        {hours, minutes, seconds} = Time.to_erl(ewd)
        total_hours = hours + minutes / 60 + seconds / 3600
        {:ok, %{cost: cost * total_hours, id: job_id, revise_cost: revise_cost}}
      else
        {:error, error} ->
          {:error, error}

        _ ->
          {:error, "Something Went Wrong."}
      end
    end
  end

  def get_job_history(_, %{input: %{job_id: job_id}}, %{context: %{current_user: _current_user}}) do
    case Jobs.get_job_history_by_job(job_id) do
      [] ->
        {:error, ["no job history"]}

      data ->
        job_history =
          Enum.map(data, fn %{updated_by: updated_by, inserted_by: inserted_by} = history ->
            history = Map.merge(history, %{inserted_by: Accounts.get_user!(inserted_by)})

            if is_nil(updated_by) do
              history
            else
              Map.merge(history, %{updated_by: Accounts.get_user!(updated_by)})
            end
          end)

        {:ok, job_history}
    end
  end

  def get_ratings_by(_, %{input: %{branch_id: branch_id} = input}, _) do
    case BSP.get_branch!(branch_id) do
      %{} = branch ->
        ratings =
          Enum.reduce(Jobs.get_ratings_by(input), [], fn
            %{inserted_by: cmr_id, updated_at: rating_date, branch_service_id: bs_id} = rating,
            acc ->
              %{name: name} = Services.get_service_by_branch_service(bs_id)

              acc ++
                [
                  Map.merge(rating, %{
                    rating_date: rating_date,
                    cmr: Accounts.get_user!(cmr_id),
                    service_name: name
                  })
                ]
          end)

        avg_rating = input |> Core.Jobs.get_ratings_avg_by() |> round_off_value(1)

        branch_services =
          Services.get_active_services_by_branch(branch_id)
          |> BusinessResolver.make_services_grouped()

        branch =
          Map.merge(branch, %{
            formatted_branch_services: branch_services,
            owner: Employees.get_owner_user_by_branch_id(branch_id)
          })
          |> BusinessResolver.add_issuing_authority_name()

        {:ok, %{branch: branch, ratings: ratings, bsp_avg_rating: avg_rating}}

      _ ->
        {:error, ["no bsp ratings"]}
    end
  end

  def get_ratings_by(_, %{input: %{user_id: user_id} = input}, _) do
    case Accounts.get_user!(user_id) do
      %{} = user ->
        ratings =
          Enum.reduce(Jobs.get_ratings_by(input), [], fn
            %{updated_at: rating_date, branch_service_id: bs_id} = rating, acc ->
              %{name: name, bsp_name: bsp_name} =
                Services.get_service_and_branch_name_by_branch_service(bs_id)

              acc ++
                [
                  Map.merge(rating, %{
                    rating_date: rating_date,
                    bsp_name: bsp_name,
                    service_name: name
                  })
                ]
          end)

        avg_rating = input |> Core.Jobs.get_ratings_avg_by() |> round_off_value(1)
        {:ok, %{user: user, ratings: ratings, cmr_avg_rating: avg_rating}}

      _ ->
        {:error, ["no cmr ratings"]}
    end
  end

  def get_distance_and_time(
        _,
        %{
          input: [
            %{
              location_src: %{lat: origin_lat, long: origin_long},
              location_dest: %{lat: dest_lat, long: dest_long}
            }
          ]
        },
        _
      ) do
    map = %{
      origin_lat: origin_lat,
      origin_long: origin_long,
      dest_lat: dest_lat,
      dest_long: dest_long
    }

    case CoreWeb.Utils.GoogleApiHandler.distance_api(map) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp post_job_if_reoccurring(
         %{
           occurrence: %{
             re_occurrence: re_occurrence,
             repeat_unit: repeat_unit,
             repeat_every: repeat_every
           }
         } = input
       ) do
    Enum.reduce_while(1..re_occurrence, %{}, fn
      1, acc ->
        input
        |> put(:is_reoccurring, true)
        |> JobController.post_job()
        |> then(fn
          {:error, error} ->
            acc |> put_and_halt(error)

          {:halt, error} ->
            acc |> put_and_halt(error)

          {:ok, job} ->
            acc |> put(:jobs, [job]) |> continue()

          [err] when is_binary(err) ->
            acc |> put_and_halt(err)

          jobs ->
            acc |> put(:jobs, jobs) |> continue()
        end)

      count, acc ->
        shift_time_opts = %{repeat_unit => count * repeat_every} |> Map.to_list()

        input
        |> get(:arrive_at)
        |> then(fn arrive_at -> Timex.shift(arrive_at, shift_time_opts) end)
        |> then(fn shifted_time -> input |> put(:arrive_at, shifted_time) end)
        |> put(:is_reoccurring, true)
        |> JobController.post_job()
        |> then(fn
          {:error, error} ->
            Enum.each(acc[:jobs], fn
              %{id: id} ->
                id |> cancel_job_post()

              _ ->
                :ok
            end)

            acc |> put_and_halt(error)

          {:ok, jobs} ->
            acc
            |> put(:jobs, acc.jobs ++ [jobs])
            |> continue()

          [err] when is_binary(err) ->
            acc |> put_and_halt(err)

          {:cont, jobs} ->
            handel_jobs(acc, jobs)

          jobs ->
            acc
            |> put(:jobs, acc.jobs ++ jobs)
            |> continue()
        end)
    end)
  end

  defp post_job_if_reoccurring(input) do
    input
    |> JobController.post_job()
    |> then(fn
      [err] when is_binary(err) ->
        err |> error()

      jobs when is_list(jobs) ->
        jobs

      rest ->
        rest
    end)
  end

  defp handel_jobs(%{jobs: acc_jobs} = acc, jobs) when is_list(acc_jobs) do
    acc
    |> put(:jobs, acc_jobs ++ jobs)
    |> continue()
  end

  defp handel_jobs(%{jobs: {:cont, acc_jobs}} = acc, jobs) do
    acc
    |> put(:jobs, acc_jobs ++ jobs)
    |> continue()
  end

  defp cancel_job_post(id) do
    JobController.update_job(%{
      id: id,
      job_status_id: "cancelled",
      job_cmr_status_id: "cancelled",
      job_bsp_status_id: "cancelled"
    })
  end

  defp put_and_halt(acc, err), do: acc |> put(:error, err) |> halt()

  def create_job_note(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    input = Map.merge(input, %{user_id: id})

    case JobController.create_job_note(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def show_job_note(_, %{input: input}, %{context: %{current_user: %{id: id}}}) do
    input = Map.merge(input, %{current_user_id: id})

    case JobController.show_job_note(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end
end
