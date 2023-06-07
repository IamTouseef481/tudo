defmodule CoreWeb.GraphQL.Resolvers.SettingResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.{Employees, Settings}
  alias CoreWeb.Controllers.SettingController

  @common_error ["Something went wrong, unable to delete Settings, try again"]

  def list_settings(_, _, _) do
    {:ok, Settings.list_settings()}
  end

  def settings_by_type(_, %{input: input}, _) do
    input
    |> Settings.settings_by_type()
    |> ok()
  end

  def encode_settings_to_use_while_updating_settings(settings, slug) do
    [fields] =
      Enum.filter(settings, fn setting ->
        if setting.slug == slug, do: setting.fields, else: false
      end)

    Poison.encode!(fields.fields)
  end

  def validity_for_setting(%{user_id: user_id, branch_id: branch_id} = _input) do
    if Employees.get_owner_or_manager_by_user_and_branch(user_id, branch_id) != nil do
      true
    else
      false
    end
  end

  def create_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    if validity_for_setting(input) do
      case SettingController.create_setting(input) do
        {:ok, setting} -> {:ok, setting}
        {:error, error} -> {:error, error}
      end
    else
      {:error, ["you don't have permission to create this setting"]}
    end
  end

  def update_settings(_, %{input: %{setting_id: setting_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})
    %{branch_id: branch_id} = Settings.get_setting!(setting_id)

    if validity_for_setting(%{user_id: current_user.id, branch_id: branch_id}) do
      case SettingController.update_setting(input) do
        {:ok, setting} -> {:ok, setting}
        {:error, error} -> {:error, error}
      end
    else
      {:error, ["you don't have permission to create this setting"]}
    end
  end

  def update_business_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    if validity_for_setting(input) do
      case SettingController.update_business_setting(input) do
        {:ok, setting} -> {:ok, setting}
        {:error, error} -> {:error, error}
      end
    else
      {:error, ["you don't have permission to create this setting"]}
    end
  end

  def create_bsp_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    if validity_for_setting(input) do
      case SettingController.create_bsp_setting(input) do
        {:ok, setting} -> {:ok, setting}
        {:error, error} -> {:error, error}
      end
    else
      {:error, ["you don't have permission to create this setting"]}
    end
  end

  def update_bsp_settings(_, %{input: %{setting_id: setting_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case Settings.get_bsp_setting(setting_id) do
      %{branch_id: branch_id} ->
        if validity_for_setting(%{user_id: current_user.id, branch_id: branch_id}) do
          case SettingController.update_bsp_setting(input) do
            {:ok, setting} -> {:ok, setting}
            {:error, error} -> {:error, error}
          end
        else
          {:error, ["you don't have permission to create this setting"]}
        end

      _ ->
        {:error, ["Error in retriving Settings"]}
    end
  end

  def get_bsp_settings_by(_, %{input: input}, _) do
    case Settings.get_bsp_settings_by(input) do
      nil -> {:ok, []}
      settings -> {:ok, settings}
    end
  end

  def delete_bsp_settings(_, %{input: %{setting_id: id}}, _) do
    case Settings.get_bsp_setting(id) do
      nil -> {:error, ["setting does not exist"]}
      %{} = setting -> Settings.delete_bsp_setting(setting)
    end
  end

  defp make_params_for_employee_details(key, input, em_id, user_id) do
    case key do
      :vehicles ->
        %{
          slug: "vehicles",
          title: "Vehicles",
          type: "employee_details",
          employee_id: em_id,
          user_id: user_id,
          fields: string_to_map(input[:vehicles])
        }

      :insurance ->
        %{
          slug: "insurance",
          title: "Insurance",
          type: "employee_details",
          employee_id: em_id,
          user_id: user_id,
          fields: string_to_map(input[:insurance])
        }

      :qualification ->
        %{
          slug: "qualification",
          title: "Qualification",
          type: "employee_details",
          employee_id: em_id,
          user_id: user_id,
          fields: string_to_map(input[:qualification])
        }

      :work_experience ->
        %{
          slug: "work_experience",
          title: "Work Experience",
          type: "employee_details",
          user_id: user_id,
          employee_id: em_id,
          fields: string_to_map(input[:work_experience])
        }

      :personal_identification ->
        %{
          slug: "personal_identification",
          title: "Personal Identification",
          type: "employee_details",
          employee_id: em_id,
          user_id: user_id,
          fields: string_to_map(input[:personal_identification])
        }

      _ ->
        nil
    end
  end

  def create_employee_details(_, %{input: %{employee_id: em_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    settings =
      Enum.reduce_while(Map.keys(input), [], fn key, acc ->
        params = make_params_for_employee_details(key, input, em_id, current_user.id)

        if params != nil do
          case Settings.get_cmr_settings_by_employee(params) do
            [] ->
              case Settings.create_cmr_settings(params) do
                {:ok, setting} ->
                  {:cont, [setting | acc]}

                _ ->
                  {:halt, {:error, ["Error while creating #{params.title} details, try again"]}}
              end

            [setting] ->
              case Settings.update_cmr_settings(setting, params) do
                {:ok, setting} ->
                  {:cont, [setting | acc]}

                _ ->
                  {:halt, {:error, ["Error while updating #{params.title} details, try again"]}}
              end

            _ ->
              {:halt, {:error, ["#{params.title} Multpiple records found for this employee!"]}}
          end
        else
          {:cont, acc}
        end
      end)

    case settings do
      {:error, error} -> {:error, error}
      settings -> {:ok, settings}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to upsert employee details"], __ENV__.line)
  end

  def create_cmr_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      if Map.has_key?(input, :fields) do
        fields = string_to_map(input.fields)
        Map.merge(input, %{fields: fields})
      else
        input
      end

    input = Map.merge(input, %{user_id: current_user.id})

    case Settings.get_cmr_settings_by_slug_and_user(input) do
      [] ->
        case Settings.create_cmr_settings(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
          _ -> {:error, ["unexpected error occurred!"]}
        end

      [_settings] ->
        {:error, ["This Consumer has already settings with this slug"]}

      _settings ->
        {:error, ["This Consumer has already more than 1 Settings with this slug"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to create settings"], __ENV__.line)
  end

  def update_cmr_settings(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if Map.has_key?(input, :fields) do
      map_fields = Enum.map(input.fields, &string_to_map(&1))

      case Settings.get_cmr_settings_by_user(id, current_user.id) do
        %{slug: "personal_identification"} = details ->
          map_fields = if is_list(map_fields), do: List.first(map_fields), else: map_fields
          input = Map.merge(input, %{fields: map_fields})
          updating_personal_identification_setting(details, input)

        %{} = setting ->
          input = Map.merge(input, %{fields: map_fields})
          updating_cmr_setting(setting, input)

        nil ->
          {:error, ["Consumer Settings missing for your User profile!"]}

        _ ->
          {:error, ["Error in fetching Consumer Settings"]}
      end
    else
      case Settings.get_cmr_settings_by_user(id, current_user.id) do
        %{} = setting -> updating_cmr_setting(setting, input)
        nil -> {:error, ["Consumer Settings missing for your User profile!"]}
        _ -> {:error, ["Error in fetching Consumer Settings"]}
      end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to update settings"], __ENV__.line)
  end

  defp updating_cmr_setting(setting, input) do
    case Settings.update_cmr_settings(setting, input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end

  defp updating_personal_identification_setting(details, input) do
    setting_fields = List.first(details.fields)
    setting_fields = keys_to_atoms(setting_fields)
    details = Map.merge(details, %{fields: setting_fields})
    input = merge_input_with_existing_settings(details, input)

    case Settings.update_cmr_settings(details, input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end

  def merge_input_with_existing_settings(setting, params) do
    updated_fields =
      Enum.reduce(setting.fields, %{}, fn {setting_key, setting_obj}, outer_acc ->
        Enum.reduce(Map.keys(params.fields), outer_acc, fn params_key, inner_acc ->
          if setting_key == params_key do
            result = Map.merge(setting_obj, params.fields[params_key])
            Map.put(inner_acc, params_key, result)
          else
            Map.put(inner_acc, setting_key, setting_obj)
          end
        end)
      end)

    updated_fields =
      Enum.reduce(params.fields, updated_fields, fn {params_key, params_obj}, outer_acc ->
        Enum.reduce(Map.keys(setting.fields), outer_acc, fn setting_key, inner_acc ->
          if setting_key != params_key do
            Map.put(inner_acc, params_key, params_obj)
          else
            inner_acc
          end
        end)
      end)

    Map.merge(params, %{fields: [updated_fields]})
  end

  def get_cmr_preference_settings(_, _, %{context: %{current_user: current_user}}) do
    case Settings.get_cmr_preference_settings(current_user.id) do
      [] -> {:error, ["Consumer Setting doesn't exist!"]}
      cmr_settings -> {:ok, cmr_settings}
    end
  end

  def get_cmr_settings_by(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case Settings.get_cmr_settings_by(input) do
      [] -> {:error, ["Consumer Setting doesn't exist!"]}
      cmr_settings -> {:ok, cmr_settings}
    end
  end

  def employee_details_get_by(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case Settings.get_cmr_settings_by(input) do
      [] -> {:error, ["Employee details doesn't exist!"]}
      cmr_settings -> {:ok, cmr_settings}
    end
  end

  def delete_cmr_settings(_, %{input: %{id: id}}, _) do
    case Settings.get_cmr_settings(id) do
      nil ->
        {:error, ["no cmr settings exist!"]}

      %{} = details ->
        case Settings.delete_cmr_settings(details) do
          {:ok, setting} -> {:ok, setting}
          {:error, error} -> {:error, error}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def tudo_settings(_, _, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      {:ok, Settings.list_tudo_settings()}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def create_tudo_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      c_id = if is_nil(input[:country_id]), do: 1, else: input[:country_id]
      input = Map.merge(input, %{user_id: current_user.id, country_id: c_id})

      case Settings.get_tudo_setting_by(input) do
        %{} ->
          {:error, ["This Setting already Exist"]}

        nil ->
          case SettingController.create_tudo_settings(input) do
            {:ok, setting} -> {:ok, setting}
            {:error, error} -> {:error, error}
          end

        _ ->
          {:error, ["Unable to process these params"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def create_tudo_settings(_, _, _), do: {:error, ["Missing Something"]}

  def update_tudo_settings(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      input = Map.merge(input, %{user_id: current_user.id})

      case Settings.get_tudo_setting(id) do
        %{} = setting ->
          case Settings.update_tudo_setting(setting, input) do
            {:ok, data} -> {:ok, data}
            {:error, changeset} -> {:error, changeset}
            _ -> {:error, ["unable to update tudo setting!"]}
          end

        nil ->
          {:error, ["doesn't exist!"]}

        _ ->
          {:error, ["Error in update_tudo_settings"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def update_tudo_settings(_, _, _), do: {:error, ["Missing Went Wrong!"]}

  def delete_tudo_settings(_, %{input: %{id: id}}, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      case Settings.get_tudo_setting(id) do
        nil ->
          {:error, ["doesn't exist!"]}

        %{} = details ->
          case Settings.delete_tudo_setting(details) do
            {:ok, setting} -> {:ok, setting}
            {:error, error} -> {:error, error}
          end

        _ ->
          {:error, ["Error in delete_tudo_settings"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def delete_tudo_settings(_, _, _), do: {:error, ["Missing Went Wrong!"]}
end
