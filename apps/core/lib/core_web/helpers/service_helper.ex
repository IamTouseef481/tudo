defmodule CoreWeb.Helpers.ServiceHelper do
  #   Core.Services.Service.Sages
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Employees, Services, Settings}

  #
  # Main actions
  #

  def create_employee_service(params) do
    new()
    |> run(:is_employee_service_exist, &is_employee_service_exist/2, &abort/3)
    |> run(:employee_service, &create_employee_service/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_employee_service(params) do
    new()
    |> run(:is_employee_service_record_exist, &is_employee_service_record_exist/2, &abort/3)
    |> run(:employee_service, &update_employee_service/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_country_service(params) do
    new()
    |> country_process()
    |> run(:cs, &get_country_service/2, &abort/3)
    |> run(:country_service, &create_country_service/2, &abort/3)
    |> run(:service_setting, &create_service_setting/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_country_service(params) do
    new()
    |> run(:is_country_service_record_exist, &is_country_service_record_exist/2, &abort/3)
    #    |> country_process()
    |> run(:country_service, &update_country_service/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # TODO: If a new branch_services added after creating a branch. Then all nearest bid_jobs will
  # be shown to this branch. Will added on create, update and delete sage.
  def create_branch_service(params) do
    new()
    |> run(:is_branch_service_exist, &is_branch_service_exist/2, &abort/3)
    |> branch_process()
    |> run(:branch_service, &create_branch_service/2, &abort/3)
    |> run(:employee_service, &creates_employee_service/2, &abort/3)
    |> run(:branch_settings, &add_service_in_branch_settings/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_branch_service(params) do
    new()
    |> run(:get_branch_service, &get_branch_service/2, &abort/3)
    |> run(:branch_service, &update_branch_service/2, &abort/3)
    |> run(:branch_settings, &add_or_remove_service_in_branch_settings/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_branch_service(params) do
    new()
    |> run(:branch_service, &get_branch_service/2, &abort/3)
    |> run(:delete_branch_service, &delete_branch_service/2, &abort/3)
    |> run(:branch_settings, &remove_service_in_branch_settings/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def country_process(sage) do
    sage
    |> run(:is_country_exist, &is_country_exist/2, &abort/3)
    |> run(:is_service_exist, &is_service_exist/2, &abort/3)
  end

  def branch_process(sage) do
    sage
    |> run(:is_country_service_exist, &is_country_service_exist/2, &abort/3)
    |> run(:is_branch_exist, &is_branch_exist/2, &abort/3)
  end

  # -----------------------------------------------

  #
  # Is country exist
  #
  defp is_country_exist(_, %{country_id: id}) do
    case Core.Regions.get_countries!(id) do
      nil -> {:error, ["country doesn't exist"]}
      %{} -> {:ok, ["valid"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country"], __ENV__.line)
  end

  #
  # Is service exist
  #

  defp create_service_setting(%{country_service: %{id: cs_id}}, _) do
    params = %{country_service_id: cs_id, fields: %{is_flexible: false, distance_limit: 30}}

    case Services.create_service_setting(params) do
      {:ok, service_setting} -> {:ok, service_setting}
      {:error, _} -> {:error, ["Service Setting not created"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to create service"], __ENV__.line)
  end

  defp is_service_exist(_, %{service_id: id}) do
    case Services.get_service(id) do
      nil -> {:error, ["service doesn't exist"]}
      %{} -> {:ok, ["valid"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch service"], __ENV__.line)
  end

  #
  # Is employee service record exist
  #
  defp is_employee_service_record_exist(_, %{id: id}) do
    case Services.get_employee_service(id) do
      nil -> {:error, ["employee service doesn't exist"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch employee service"], __ENV__.line)
  end

  #
  # Is employee service exist
  #
  defp is_employee_service_exist(_, %{
         branch_service_id: branch_service_id,
         employee_id: employee_id
       }) do
    case Services.get_employee_service_by(branch_service_id, employee_id) do
      [] ->
        {:ok, []}

      [data] ->
        {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch employee service"], __ENV__.line)
  end

  #
  # Is country service exist
  #
  defp is_country_service_record_exist(_, %{id: id}) do
    case Services.get_country_service(id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country service"], __ENV__.line)
  end

  #
  # Is country service exist
  #
  defp get_country_service(_, params) do
    case Services.get_country_service_by_country_and_service(params) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["country service already exist"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country service"], __ENV__.line)
  end

  defp is_country_service_exist(_, %{country_service_id: id}) do
    case Services.get_active_country_service(id) do
      nil -> {:error, ["active country service doesn't exist"]}
      _ -> {:ok, ["valid"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country service"], __ENV__.line)
  end

  defp is_country_service_exist(_, _params) do
    {:ok, ["valid"]}
  end

  #
  # Is branch exist
  #
  defp is_branch_exist(_, %{branch_id: id}) do
    case Core.BSP.get_branch!(id) do
      nil -> {:error, ["branch doesn't exist"]}
      %{} -> {:ok, ["valid"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch branch"], __ENV__.line)
  end

  defp is_branch_exist(_, _params) do
    {:ok, ["valid"]}
  end

  #  def set_branch_services(params) do
  #    new()
  #    |> run(:branch_services, &set_branch_services/2, &abort/3)
  #    |> transaction(Core.Repo, params)
  #  end
  #
  #  def set_branch_services(_, params) do
  #    result = params |> Enum.map(&upsert_branch_services/1)
  #    {:ok, %{branch_services: result}}
  #  end
  #
  #  defp upsert_branch_services(%{branch_id: branch_id, country_service_id: id}=params) do
  #    case Services.get_branch_services_by_branch_id(branch_id, id) do
  #      [] -> Services.create_branch_service(params)
  #      data -> Services.update_branch_service(data, params)
  #    end
  #  rescue
  #    _-> {:error, ["enable to upsert branch services"]}
  #  end

  #  defp upsert_branch_services(_, _) do
  #    {:ok, :not_applicable}
  #  end

  defp is_branch_service_exist(
         _,
         %{
           branch_id: branch_id,
           country_service_id: country_service_id,
           service_type_id: service_type
         } = _params
       ) do
    case Services.get_branch_services_by(%{
           branch_id: branch_id,
           country_service_id: country_service_id,
           service_type_id: service_type
         }) do
      [] -> {:ok, []}
      _ -> {:error, ["branch service already exist for given parameters"]}
    end
  end

  defp get_branch_service(_, %{id: id} = _params) do
    case Services.get_branch_service(id) do
      nil -> {:error, ["branch service does not exist"]}
      service -> {:ok, service}
    end
  end

  defp create_branch_service(%{is_branch_service_exist: []} = _effects_so_far, params) do
    case Services.create_branch_service(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Error in creating Branch Service"]}
    end
  end

  defp creates_employee_service(%{branch_service: %{id: bs_id, branch_id: branch_id}}, _params) do
    case Employees.get_owner_by_branch_id(branch_id) do
      %{id: employee_id} ->
        params = %{
          employee_id: employee_id,
          branch_service_id: bs_id,
          start_date: ~U[2019-01-01 04:11:08.589187Z],
          end_date: ~U[2120-12-31 23:59:59Z]
        }

        case Services.create_employee_service(params) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
          _ -> {:error, ["error in employee service creation"]}
        end

      _ ->
        {:error, ["unable to fetch owner for creating employee service"]}
    end
  end

  defp add_service_in_branch_settings(
         %{
           branch_service:
             %{branch_id: _branch_id, country_service_id: _, service_type_id: _service_type} =
               branch_service
         } = _effects_so_far,
         _params
       ) do
    with {:ok, _setting} <- add_service_for_branch_radius_setting(branch_service),
         {:ok, _setting} <-
           add_service_for_branch_services_expected_work_duration_setting(branch_service),
         {:ok, _setting} <- add_service_for_branch_service_rates_setting(branch_service),
         {:ok, _setting} <- add_service_for_branch_sales_tax_setting(branch_service),
         {:ok, setting} <- add_service_for_branch_service_cost_estimate_setting(branch_service) do
      {:ok, setting}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["error while updating settings"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Branch settings on creating Service failed, try again"],
        __ENV__.line
      )
  end

  defp add_or_remove_service_in_branch_settings(
         %{
           get_branch_service: %{is_active: false},
           branch_service: %{is_active: true} = branch_service
         } = _effects_so_far,
         params
       ) do
    add_service_in_branch_settings(%{branch_service: branch_service}, params)
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["unable to update branch settings on updating branch service!"],
        __ENV__.line
      )
  end

  defp add_or_remove_service_in_branch_settings(
         %{
           get_branch_service: %{is_active: true},
           branch_service: %{is_active: false} = branch_service
         } = _effects_so_far,
         params
       ) do
    remove_service_in_branch_settings(%{branch_service: branch_service}, params)
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["unable to update branch settings on updating branch service!"],
        __ENV__.line
      )
  end

  defp add_or_remove_service_in_branch_settings(_effects_so_far, _params) do
    {:ok, ["no need to update branch settings!"]}
  end

  defp add_service_for_branch_radius_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_radius"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        %{name: name} = Services.get_service_by_country_service(cs_id)

        s =
          services["#{service_type}"] ++
            [%{"radius" => 50, "country_service_id" => cs_id, "name" => name}]

        updated_services = Map.merge(services, %{"#{service_type}" => s})
        updated_fields = Map.merge(fields, %{"services" => updated_services})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["Something went wrong in updating Settings"]}
        end

      _ ->
        {:ok, ["Service Radius settings missing for this Branch"]}
    end
  end

  defp add_service_for_branch_services_expected_work_duration_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_expected_work_duration"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        %{name: name} = Services.get_service_by_country_service(cs_id)

        s =
          services["#{service_type}"] ++
            [
              %{
                "expected_work_duration" => "01:00:00",
                "country_service_id" => cs_id,
                "name" => name
              }
            ]

        updated_services = Map.merge(services, %{"#{service_type}" => s})
        updated_fields = Map.merge(fields, %{"services" => updated_services})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["Something went wrong in updating Settings"]}
        end

      _ ->
        {:ok, ["Services Expected Work Duration settings missing for this Branch"]}
    end
  end

  defp add_service_for_branch_service_rates_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_rates"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        %{name: name} = Services.get_service_by_country_service(cs_id)

        s =
          services["#{service_type}"] ++
            [%{"price_amount" => 20.50, "country_service_id" => cs_id, "name" => name}]

        updated_services = Map.merge(services, %{"#{service_type}" => s})
        updated_fields = Map.merge(fields, %{"services" => updated_services})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["Something went wrong in updating Settings"]}
        end

      _ ->
        {:ok, ["Services Rate settings missing for this Branch"]}
    end
  end

  defp add_service_for_branch_sales_tax_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "sales_tax_rate"}) do
      %{fields: %{"service_rate_card" => srcs} = fields} = setting ->
        updated_srcs =
          Enum.map(srcs, fn %{"services" => services} = src ->
            %{name: name} = Services.get_service_by_country_service(cs_id)

            updated_services =
              services ++
                [
                  %{
                    "tax_rate" => 12,
                    "tax_title" => "GST",
                    "service_type_id" => service_type,
                    "country_service_id" => cs_id,
                    "name" => name
                  }
                ]

            Map.merge(src, %{"services" => updated_services})
          end)

        updated_fields = Map.merge(fields, %{"service_rate_card" => updated_srcs})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["error in updating setting"]}
        end

      _ ->
        {:ok, ["Service Sales Tax settings missing for this Branch"]}
    end
  end

  defp add_service_for_branch_service_cost_estimate_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "service_cost_estimate"}) do
      %{fields: %{"services_estimates" => services} = fields} = setting ->
        %{name: name} = Services.get_service_by_country_service(cs_id)

        s =
          services["#{service_type}"] ++
            [
              %{
                "price_amount" => 20.50,
                "final_amount" => 124.25,
                "duration_minutes" => 60,
                "country_service_id" => cs_id,
                "name" => name
              }
            ]

        updated_services = Map.merge(services, %{"#{service_type}" => s})
        updated_fields = Map.merge(fields, %{"services_estimates" => updated_services})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["Something went wrong in updating Settings"]}
        end

      _ ->
        {:ok, ["Services Rate settings missing for this Branch"]}
    end
  end

  defp remove_service_in_branch_settings(
         %{
           branch_service:
             %{branch_id: _branch_id, country_service_id: _cs_id, service_type_id: _service_type} =
               branch_service
         } = _effects_so_far,
         _params
       ) do
    with {:ok, _setting} <- remove_service_from_branch_radius_setting(branch_service),
         {:ok, _setting} <-
           remove_service_from_branch_services_expected_work_duration_setting(branch_service),
         {:ok, _setting} <- remove_service_for_branch_service_rates_setting(branch_service),
         {:ok, _setting} <- remove_service_for_branch_sales_tax_setting(branch_service),
         {:ok, setting} <- remove_service_for_branch_service_cost_estimate_setting(branch_service) do
      {:ok, setting}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong in updating Settings"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Branch settings on creating Service failed, try again"],
        __ENV__.line
      )
  end

  defp remove_service_from_branch_radius_setting(
         %{branch_id: branch_id, country_service_id: cs_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_radius"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        updated_services =
          Enum.reduce(services["#{service_type}"], [], fn service, acc ->
            if service["country_service_id"] == cs_id do
              acc
            else
              [service | acc]
            end
          end)

        updated_services = Map.merge(services, %{"#{service_type}" => updated_services})
        updated_fields = Map.merge(fields, %{"services" => updated_services})
        Settings.update_setting(setting, %{fields: updated_fields})

      _ ->
        {:ok, ["Service Radius settings missing for this Branch"]}
    end
  end

  defp remove_service_from_branch_services_expected_work_duration_setting(
         %{branch_id: branch_id, country_service_id: cs_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_expected_work_duration"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        updated_services =
          Enum.reduce(services["#{service_type}"], [], fn service, acc ->
            if service["country_service_id"] == cs_id do
              acc
            else
              [service | acc]
            end
          end)

        updated_services = Map.merge(services, %{"#{service_type}" => updated_services})
        updated_fields = Map.merge(fields, %{"services" => updated_services})
        Settings.update_setting(setting, %{fields: updated_fields})

      _ ->
        {:ok, ["Service Radius settings missing for this Branch"]}
    end
  end

  defp remove_service_for_branch_service_rates_setting(
         %{branch_id: branch_id, country_service_id: cs_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "services_rates"}) do
      %{fields: %{"services" => services} = fields} = setting ->
        updated_services =
          Enum.reduce(services["#{service_type}"], [], fn service, acc ->
            if service["country_service_id"] == cs_id do
              acc
            else
              [service | acc]
            end
          end)

        updated_services = Map.merge(services, %{"#{service_type}" => updated_services})
        updated_fields = Map.merge(fields, %{"services" => updated_services})
        Settings.update_setting(setting, %{fields: updated_fields})

      _ ->
        {:ok, ["no service rates settings exists for this branch"]}
    end
  end

  defp remove_service_for_branch_sales_tax_setting(
         %{country_service_id: cs_id, branch_id: branch_id, service_type_id: _service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "sales_tax_rate"}) do
      %{fields: %{"service_rate_card" => srcs} = fields} = setting ->
        updated_srcs =
          Enum.map(srcs, fn %{"services" => services} = src ->
            %{name: _name} = Services.get_service_by_country_service(cs_id)

            updated_services =
              Enum.reduce(services, [], fn service, acc ->
                if service["country_service_id"] == cs_id do
                  acc
                else
                  [service | acc]
                end
              end)

            Map.merge(src, %{"services" => updated_services})
          end)

        updated_fields = Map.merge(fields, %{"service_rate_card" => updated_srcs})

        case Settings.update_setting(setting, %{fields: updated_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["error in updating setting"]}
        end

      _ ->
        {:ok, ["Service Sales Tax settings missing for this Branch"]}
    end
  end

  defp remove_service_for_branch_service_cost_estimate_setting(
         %{branch_id: branch_id, country_service_id: cs_id, service_type_id: service_type} =
           _branch_service
       ) do
    case Settings.get_settings_by(%{branch_id: branch_id, slug: "service_cost_estimate"}) do
      %{fields: %{"services_estimates" => services} = fields} = setting ->
        updated_services =
          Enum.reduce(services["#{service_type}"], [], fn service, acc ->
            if service["country_service_id"] == cs_id do
              acc
            else
              [service | acc]
            end
          end)

        updated_services = Map.merge(services, %{"#{service_type}" => updated_services})
        updated_fields = Map.merge(fields, %{"services_estimates" => updated_services})
        Settings.update_setting(setting, %{fields: updated_fields})

      _ ->
        {:ok, ["no service rates settings exists for this branch"]}
    end
  end

  defp delete_branch_service(%{branch_service: branch_service} = _effects_so_far, _params) do
    case Services.delete_branch_service(branch_service) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["error in branch service deletion"]}
    end
  end

  defp update_branch_service(%{get_branch_service: changeset} = _effects_so_far, params) do
    case Services.update_branch_service(changeset, params) do
      {:ok, branch_service} -> {:ok, branch_service}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Error while updating Branch Service"]}
    end
  end

  defp create_country_service(_, params) do
    params |> Services.create_country_service()
  end

  defp update_country_service(
         %{is_country_service_record_exist: changeset} = _effects_so_far,
         params
       ) do
    Services.update_country_service(changeset, params)
  end

  defp create_employee_service(%{is_employee_service_exist: []} = _effects_so_far, params) do
    params |> Services.create_employee_service()
  end

  defp create_employee_service(%{is_employee_service_exist: changeset} = _effects_so_far, params) do
    Services.update_employee_service(changeset, params)
  end

  defp update_employee_service(%{is_employee_service_record_exist: changeset}, params) do
    Services.update_employee_service(changeset, params)
  end

  def create_services_along_with_country_services_sage(params) do
    new()
    |> run(:create_service, &create_services_along_with_country_services/2, &abort/3)
    |> run(:create_country_service, &create_country_service_along_with_services/2, &abort/3)
    |> run(:create_service_settings, &create_services_along_with_services_settings/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_services_along_with_country_services(_, %{input: input}) do
    params = %{
      name: input.service_name,
      service_type_id: input.service_type_id,
      service_group_id: input.service_group_id,
      service_status_id: "active"
    }

    with nil <- Services.get_service_by(params),
         {:ok, data} <- Services.create_service(params) do
      {:ok, data}
    else
      _ -> {:error, ["Already Exists"]}
      {:ok, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch services"], __ENV__.line)
  end

  def create_country_service_along_with_services(%{create_service: create_service}, %{
        input: input
      }) do
    result =
      Enum.reduce(input.country_ids, [], fn country_ids, acc ->
        with [] <-
               Services.get_country_service_by_country_ids_and_service_id(%{
                 country_ids: country_ids,
                 service_id: create_service.id
               }),
             {:ok, data} <-
               Services.create_country_service(%{
                 country_id: country_ids,
                 service_id: create_service.id,
                 is_active: true,
                 dynamic_field_id: 1
               }) do
          [data | acc]
        else
          {:error, error} -> {:error, error}
          _ -> {:error, ["Already Exists"]}
        end
      end)

    {:ok, result}
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch country services"], __ENV__.line)
  end

  def create_services_along_with_services_settings(
        %{create_country_service: create_country_service},
        %{input: input}
      ) do
    result =
      Enum.reduce(List.flatten(create_country_service), [], fn country_service, acc ->
        with [] <- Services.get_service_setting_by_country_service_id(country_service.id),
             {:ok, data} <-
               Services.create_service_setting(%{
                 country_service_id: country_service.id,
                 fields: input.service_setting_field
               }) do
          [data | acc]
        else
          {:error, error} -> {:error, error}
          _ -> {:error, ["Already Exists"]}
        end
      end)

    {:ok, result}
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to fetch services settings"], __ENV__.line)
  end
end
