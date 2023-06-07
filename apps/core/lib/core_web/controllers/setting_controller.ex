defmodule CoreWeb.Controllers.SettingController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Schemas.Setting
  alias Core.{Services, Settings}

  @common_error ["Something went wrong, try again!"]

  # -------------------------------settings----------------------------------------
  def create_setting(input) do
    case Settings.create_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, _} -> {:error, @common_error}
    end
  end

  def update_setting(%{setting_id: setting_id, slug: "availability", type: "branch"} = input) do
    case Settings.get_setting!(setting_id) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{} = setting ->
        input = put_in(input, [:fields, "default"], setting.fields["default"])
        update_setting(setting, input)
    end
  end

  def update_setting(%{setting_id: setting_id} = input) do
    case Settings.get_setting!(setting_id) do
      nil -> {:error, ["settings does not exist!"]}
      %Core.Schemas.Setting{} = setting -> update_setting(setting, input)
    end
  end

  defp update_setting(old_settings, params) do
    case Settings.update_setting(old_settings, params) do
      {:ok, setting} -> {:ok, setting}
      {:error, _} -> {:error, @common_error}
    end
  end

  # -------------------------------bsp_settings----------------------------------------
  def create_bsp_setting(input) do
    input =
      case input do
        %{fields: fields} ->
          Map.merge(input, %{fields: string_to_map(fields)})

        _ ->
          input
      end

    case Settings.get_bsp_settings_by(%{branch_id: input.branch_id, slug: input.slug}) do
      nil ->
        case Settings.create_bsp_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, _} -> {:error, @common_error}
        end

      %{} = setting ->
        Settings.update_bsp_setting(setting, input)
    end
  end

  def update_bsp_setting(%{setting_id: setting_id} = input) do
    input =
      case input do
        %{fields: fields} ->
          Map.merge(input, %{fields: string_to_map(fields)})

        _ ->
          input
      end

    case Settings.get_bsp_setting(setting_id) do
      nil ->
        case Settings.create_bsp_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, _} -> {:error, @common_error}
        end

      %{} = setting ->
        Settings.update_bsp_setting(setting, input)
    end
  end

  def update_business_setting(%{fields: fields, slug: "services_expected_work_duration"} = input) do
    fields = string_to_map(fields)
    input = Map.merge(input, %{fields: fields})

    case Settings.get_settings_by(%{branch_id: input.branch_id, slug: input.slug}) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{} = setting ->
        case Settings.update_setting(setting, input) do
          {:ok, setting} ->
            update_cost_estimate_settings_on_updating_ewd(input, "service_cost_estimate")
            {:ok, setting}

          {:error, error} ->
            {:error, error}
        end
    end
  end

  def update_business_setting(%{fields: fields, slug: "services_rates"} = input) do
    fields = string_to_map(fields)
    input = Map.merge(input, %{fields: fields})

    case Settings.get_settings_by(%{branch_id: input.branch_id, slug: input.slug}) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{} = setting ->
        case Settings.update_setting(setting, input) do
          {:ok, setting} ->
            update_cost_estimate_settings_on_updating_service_rates(
              input,
              "service_cost_estimate"
            )

            {:ok, setting}

          {:error, error} ->
            {:error, error}
        end
    end
  end

  def update_business_setting(%{fields: fields, slug: slug, branch_id: branch_id} = input) do
    fields = string_to_map(fields)
    input = Map.merge(input, %{fields: fields})

    case Settings.get_settings_by(%{branch_id: branch_id, slug: slug}) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{} = setting ->
        case Settings.update_setting(setting, input) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
        end
    end
  end

  def update_business_setting(input) do
    case Settings.get_settings_by(input) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Setting{} = setting ->
        case Settings.update_setting(setting, input) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp update_cost_estimate_settings_on_updating_ewd(%{branch_id: branch_id} = input, slug) do
    ewd_setting = Settings.get_settings_by(%{branch_id: branch_id, slug: input.slug})

    case Settings.get_settings_by(%{branch_id: branch_id, slug: slug}) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{fields: sce_setting} = setting ->
        updated_sce_fields =
          update_service_cost_estimate_setting_on_updating_ewd(ewd_setting.fields, sce_setting)

        case Settings.update_setting(setting, %{fields: updated_sce_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp update_service_cost_estimate_setting_on_updating_ewd(ewd_setting, sce_setting) do
    Enum.reduce(Services.list_service_types(), sce_setting, fn %{id: type_id}, type_acc ->
      if ewd_setting["same_for_all_for_#{type_id}"] do
        service_settings =
          Enum.reduce(sce_setting["services_estimates"]["#{type_id}"], [], fn service,
                                                                              service_acc ->
            #          [time | tail] = String.split(ewd_setting["default_for_#{type_id}"], " ")
            {hours, minutes, seconds} =
              ewd_setting["default_for_#{type_id}"] |> Time.from_iso8601!() |> Time.to_erl()

            duration_minutes = hours * 60 + minutes + seconds / 60
            service = Map.merge(service, %{"duration_minutes" => duration_minutes})
            [service | service_acc]
          end)

        estimates = Map.merge(type_acc["services_estimates"], %{"#{type_id}" => service_settings})
        Map.merge(type_acc, %{"services_estimates" => estimates})
      else
        logger(__MODULE__, ewd_setting["services"]["#{type_id}"], :info, __ENV__.line)

        service_settings =
          Enum.reduce(sce_setting["services_estimates"]["#{type_id}"], [], fn service,
                                                                              service_acc ->
            updated_rec =
              Enum.reduce_while(ewd_setting["services"]["#{type_id}"], %{}, fn ewd_set,
                                                                               _ewd_set_acc ->
                if ewd_set["country_service_id"] == service["country_service_id"] do
                  #              [time | tail] = String.split(ewd_set["expected_work_duration"], " ")
                  {hours, minutes, seconds} =
                    ewd_set["expected_work_duration"] |> Time.from_iso8601!() |> Time.to_erl()

                  duration_minutes = hours * 60 + minutes + seconds / 60
                  updated_service = Map.merge(service, %{"duration_minutes" => duration_minutes})
                  {:halt, updated_service}
                else
                  {:cont, service}
                end
              end)

            [updated_rec | service_acc]
          end)

        estimates = Map.merge(type_acc["services_estimates"], %{"#{type_id}" => service_settings})
        Map.merge(type_acc, %{"services_estimates" => estimates})
      end
    end)
  end

  defp update_cost_estimate_settings_on_updating_service_rates(
         %{branch_id: branch_id} = input,
         slug
       ) do
    %{fields: rates_setting} = Settings.get_settings_by(%{branch_id: branch_id, slug: input.slug})

    case Settings.get_settings_by(%{branch_id: branch_id, slug: slug}) do
      nil ->
        {:error, ["settings does not exist!"]}

      %Core.Schemas.Setting{fields: sce_setting} = setting ->
        sce_setting =
          Map.merge(sce_setting, %{
            "rate_type_for_walk_in" => rates_setting["rate_type_for_walk_in"],
            "rate_type_for_on_demand" => rates_setting["rate_type_for_on_demand"],
            "rate_type_for_home_service" => rates_setting["rate_type_for_home_service"]
          })

        updated_sce_fields =
          update_service_cost_estimate_setting_on_updating_service_rates(
            rates_setting,
            sce_setting
          )

        case Settings.update_setting(setting, %{fields: updated_sce_fields}) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp update_service_cost_estimate_setting_on_updating_service_rates(rates_setting, sce_setting) do
    Enum.reduce(Services.list_service_types(), sce_setting, fn %{id: type_id}, type_acc ->
      if rates_setting["same_for_all_for_#{type_id}"] do
        service_settings =
          Enum.reduce(sce_setting["services_estimates"]["#{type_id}"], [], fn service,
                                                                              service_acc ->
            service =
              Map.merge(service, %{"price_amount" => rates_setting["common_price_for_#{type_id}"]})

            [service | service_acc]
          end)

        estimates = Map.merge(type_acc["services_estimates"], %{"#{type_id}" => service_settings})
        Map.merge(type_acc, %{"services_estimates" => estimates})
      else
        service_settings =
          Enum.reduce(sce_setting["services_estimates"]["#{type_id}"], [], fn service,
                                                                              service_acc ->
            updated_rec =
              Enum.reduce_while(rates_setting["services"]["#{type_id}"], %{}, fn rates_set,
                                                                                 _rates_set_acc ->
                if rates_set["country_service_id"] == service["country_service_id"] do
                  updated_service =
                    Map.merge(service, %{"price_amount" => rates_set["price_amount"]})

                  {:halt, updated_service}
                else
                  {:cont, service}
                end
              end)

            [updated_rec | service_acc]
          end)

        estimates = Map.merge(type_acc["services_estimates"], %{"#{type_id}" => service_settings})
        Map.merge(type_acc, %{"services_estimates" => estimates})
      end
    end)
  end

  # -------------------------------tudo_settings----------------------------------------
  def create_tudo_settings(input) do
    case Settings.create_tudo_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, _} -> {:error, @common_error}
    end
  end

  def update_tudo_setting(%{setting_id: setting_id} = input) do
    input =
      case input do
        %{fields: fields} ->
          Map.merge(input, %{fields: string_to_map(fields)})

        _ ->
          input
      end

    case Settings.get_bsp_setting(setting_id) do
      nil ->
        case Settings.create_bsp_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, _} -> {:error, @common_error}
        end

      %{} = setting ->
        Settings.update_bsp_setting(setting, input)
    end
  end

  # -------------------------------common_functions----------------------------------------
  def index(conn, _params) do
    settings = Settings.list_settings()
    render(conn, "index.html", settings: settings)
  end

  def new(conn, _params) do
    changeset = Settings.change_setting(%Setting{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"setting" => setting_params}) do
    case Settings.create_setting(setting_params) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    setting = Settings.get_setting!(id)
    render(conn, "show.html", setting: setting)
  end

  def edit(conn, %{"id" => id}) do
    setting = Settings.get_setting!(id)
    changeset = Settings.change_setting(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(conn, %{"id" => id, "setting" => setting_params}) do
    setting = Settings.get_setting!(id)

    case Settings.update_setting(setting, setting_params) do
      {:ok, _setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", setting: setting, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    setting = Settings.get_setting!(id)
    {:ok, _setting} = Settings.delete_setting(setting)

    conn
    |> put_flash(:info, "Setting deleted successfully.")
  end
end
