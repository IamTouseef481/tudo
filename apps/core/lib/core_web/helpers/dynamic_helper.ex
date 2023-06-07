defmodule CoreWeb.Helpers.DynamicHelper do
  #   Core.Dynamics.Dynamic.Sages
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{BSP, Dynamics, Services}

  #
  # Main actions
  #
  def create_dynamic_screen(params) do
    new()
    |> run(:check_foreign_keys, &check_foreign_keys_for_screen/2, &abort/3)
    |> run(:valid_dynamic_screen, &valid_dynamic_screen/2, &abort/3)
    |> run(:dynamic_screen, &create_dynamic_screen/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_dynamic_screen(params) do
    new()
    |> run(:check_foreign_keys, &check_foreign_keys_for_screen/2, &abort/3)
    |> run(:get_dynamic_screen, &get_dynamic_screen/2, &abort/3)
    |> run(:dynamic_screen, &update_dynamic_screen/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_dynamic_group(params) do
    new()
    |> run(:check_foreign_keys, &check_foreign_keys_for_group/2, &abort/3)
    |> run(:valid_dynamic_group, &valid_dynamic_group/2, &abort/3)
    |> run(:dynamic_group, &create_dynamic_group/2, &abort/3)
    |> run(:dynamic_screen_group, &create_dynamic_screen_group/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_dynamic_group(params) do
    new()
    |> run(:check_foreign_keys, &check_foreign_keys_for_group/2, &abort/3)
    |> run(:get_dynamic_group, &get_dynamic_group/2, &abort/3)
    |> run(:dynamic_group, &update_dynamic_group/2, &abort/3)
    |> run(:dynamic_screen_group, &update_dynamic_screen_group/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_dynamic_screen(params) do
    new()
    |> run(:get_dynamic_screen_groups, &get_dynamic_screen_groups_for_delete/2, &abort/3)
    |> run(:dynamic_screen_groups, &delete_dynamic_screen_group/2, &abort/3)
    |> run(:dynamic_screen, &delete_dynamic_screen/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_dynamic_group(params) do
    new()
    |> run(:get_dynamic_screen_groups, &get_dynamic_screen_groups_for_delete/2, &abort/3)
    |> run(:dynamic_screen_groups, &delete_dynamic_screen_group/2, &abort/3)
    |> run(:dynamic_group, &delete_dynamic_group/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp check_foreign_keys_for_screen(_, %{
         business_id: business_id,
         country_service_id: country_service_id
       }) do
    if BSP.get_business(business_id) != nil and
         Services.get_country_service(country_service_id) != nil do
      {:ok, ["valid"]}
    else
      {:error, ["invalid business_id or country_service_id"]}
    end
  end

  defp check_foreign_keys_for_screen(_, %{country_service_id: country_service_id}) do
    if Services.get_country_service(country_service_id) != nil do
      {:ok, ["valid"]}
    else
      {:error, ["invalid business_id or country_service_id"]}
    end
  end

  defp check_foreign_keys_for_screen(_, %{business_id: business_id}) do
    if BSP.get_business(business_id) != nil do
      {:ok, ["valid"]}
    else
      {:error, ["invalid business_id or country_service_id"]}
    end
  end

  defp check_foreign_keys_for_screen(_, _) do
    {:ok, ["valid"]}
  end

  defp valid_dynamic_screen(_, %{
         business_id: business_id,
         country_service_id: country_service_id,
         name: name
       }) do
    case Dynamics.get_dynamic_screen(business_id, country_service_id, name) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["Dynamic Screen already exists for this Business and Country Service"]}
    end
  end

  defp valid_dynamic_screen(_, %{country_service_id: country_service_id, name: name}) do
    case Dynamics.get_dynamic_screen(country_service_id, name) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["Dynamic Screen already exists for this Country Service"]}
    end
  end

  defp create_dynamic_screen(_, params) do
    case Dynamics.create_dynamic_screen(params) do
      {:ok, screen} -> {:ok, screen}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp get_dynamic_screen(_, %{id: id}) do
    case Dynamics.get_dynamic_screen(id) do
      nil -> {:error, ["dynamic screen doesn't exist"]}
      %{} = screen -> {:ok, screen}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp update_dynamic_screen(%{get_dynamic_screen: dynamic_screen}, params) do
    case Dynamics.update_dynamic_screen(dynamic_screen, params) do
      {:ok, screen} -> {:ok, screen}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp check_foreign_keys_for_group(_, %{business_id: business_id, dynamic_screen_id: screen_id}) do
    if BSP.get_business(business_id) != nil and Dynamics.get_dynamic_screen(screen_id) != nil do
      {:ok, ["valid"]}
    else
      {:error, ["Business and/ or Dynamic Screen is incorrect!"]}
    end
  end

  defp check_foreign_keys_for_group(_, %{dynamic_screen_id: screen_id}) do
    if Dynamics.get_dynamic_screen(screen_id) != nil do
      {:ok, ["valid"]}
    else
      {:error, ["Dynamic Screen is in correct!"]}
    end
  end

  defp check_foreign_keys_for_group(_, _) do
    {:ok, "valid"}
  end

  defp valid_dynamic_group(_, %{
         business_id: business_id,
         dynamic_screen_id: dynamic_screen_id,
         name: name
       }) do
    case Dynamics.get_dynamic_group(business_id, dynamic_screen_id, name) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["Dynamic group already exists"]}
    end
  end

  defp create_dynamic_group(_, params) do
    case Dynamics.create_dynamic_group(params) do
      {:ok, dynamic_group} -> {:ok, dynamic_group}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp create_dynamic_screen_group(
         %{dynamic_group: %{id: group_id}},
         %{dynamic_screen_id: screen_id, dynamic_group_order: group_order} = params
       ) do
    params =
      Map.merge(params, %{
        dynamic_scree_id: screen_id,
        dynamic_group_id: group_id,
        dynamic_group_order: group_order
      })

    case Dynamics.create_dynamic_screen_group(params) do
      {:ok, dynamic_screen_group} -> {:ok, dynamic_screen_group}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp get_dynamic_group(_, %{id: group_id, dynamic_screen_id: dynamic_screen_id}) do
    case Dynamics.get_dynamic_group(group_id, dynamic_screen_id) do
      [] -> {:error, ["dynamic_screen doesn't exist"]}
      [group] -> {:ok, group}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp update_dynamic_group(%{get_dynamic_group: %{dynamic_group: dynamic_group}}, params) do
    case Dynamics.update_dynamic_group(dynamic_group, params) do
      {:ok, dynamic_group} -> {:ok, dynamic_group}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp update_dynamic_screen_group(
         %{dynamic_group: dynamic_group},
         %{new_dynamic_screen_id: screen_id, new_dynamic_group_id: group_id} = params
       ) do
    if Dynamics.get_dynamic_group(group_id) != nil and
         Dynamics.get_dynamic_screen(screen_id) != nil do
      [data] = Dynamics.get_dynamic_screen_group(params.id, params.dynamic_screen_id)
      params = Map.merge(params, %{dynamic_screen_id: screen_id, dynamic_group_id: group_id})
      update_screen_group(dynamic_group, data, params)
    else
      {:error, ["Dynamic group or screen doesn't exist!"]}
    end
  end

  defp update_dynamic_screen_group(
         %{dynamic_group: dynamic_group},
         %{new_dynamic_group_id: group_id} = params
       ) do
    if Dynamics.get_dynamic_group(group_id) != nil do
      [data] = Dynamics.get_dynamic_screen_group(params.id, params.dynamic_screen_id)
      params = Map.merge(params, %{dynamic_group_id: group_id})
      update_screen_group(dynamic_group, data, params)
    else
      {:error, ["Dynamic group doesn't exist!"]}
    end
  end

  defp update_dynamic_screen_group(
         %{dynamic_group: dynamic_group},
         %{new_dynamic_screen_id: screen_id} = params
       ) do
    if Dynamics.get_dynamic_screen(screen_id) != nil do
      [data] = Dynamics.get_dynamic_screen_group(params.id, params.dynamic_screen_id)
      params = Map.merge(params, %{dynamic_screen_id: screen_id})
      update_screen_group(dynamic_group, data, params)
    else
      {:error, ["Dynamic screen doesn't exist!"]}
    end
  end

  defp update_dynamic_screen_group(%{dynamic_group: dynamic_group}, params) do
    [data] = Dynamics.get_dynamic_screen_group(params.id, params.dynamic_screen_id)
    update_screen_group(dynamic_group, data, params)
  end

  defp update_screen_group(dynamic_group, screen_group, params) do
    case Dynamics.update_dynamic_screen_group(screen_group, params) do
      {:ok, %{dynamic_group_order: order, dynamic_screen_id: screen_id}} ->
        {:ok,
         Map.merge(dynamic_group, %{dynamic_group_order: order, dynamic_screen_id: screen_id})}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["unexpected error occurred"]}
    end
  end

  defp get_dynamic_screen_groups_for_delete(_, params) do
    case Dynamics.get_dynamic_screen_group_by(params) do
      [] -> {:error, ["Dynamic Screen and Group relationship doesn't exist"]}
      screen_groups -> {:ok, screen_groups}
    end
  end

  defp delete_dynamic_screen_group(%{get_dynamic_screen_groups: screen_groups}, _) do
    screen_groups =
      Enum.reduce(screen_groups, [], fn screen_group, acc ->
        case Dynamics.delete_dynamic_screen_group(screen_group) do
          {:ok, data} -> [data | acc]
          _ -> acc
        end
      end)

    {:ok, screen_groups}
  end

  defp delete_dynamic_screen(_, %{dynamic_screen_id: id}) do
    case Dynamics.get_dynamic_screen(id) do
      nil -> {:error, ["dynamic screen doesn't exist"]}
      %{} = screen -> Dynamics.delete_dynamic_screen(screen)
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp delete_dynamic_group(_, %{dynamic_group_id: id}) do
    case Dynamics.get_dynamic_group(id) do
      nil -> {:error, ["dynamic group doesn't exist"]}
      %{} = group -> Dynamics.delete_dynamic_group(group)
      _ -> {:error, ["unexpected error occurred"]}
    end
  end
end
