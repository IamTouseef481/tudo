defmodule CoreWeb.Controllers.DynamicController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{BSP, Dynamics}
  alias CoreWeb.Helpers.DynamicHelper

  @common_error ["that business doesn't belongs to you!"]
  @dynamic_field_error ["dynamic field doesn't exist"]
  @default_error ["unexpected error occurred"]

  def create_dynamic_field(%{fixed: fixed} = params) do
    if check_business(params) do
      params = Map.merge(params, %{fixed: string_to_map(fixed)})

      case Dynamics.create_dynamic_field(params) do
        {:ok, dynamic_field} -> {:ok, dynamic_field}
        {:error, error} -> {:error, error}
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  end

  def create_dynamic_field(params) do
    if check_business(params) do
      case Dynamics.create_dynamic_field(params) do
        {:ok, dynamic_field} -> {:ok, dynamic_field}
        {:error, error} -> {:error, error}
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  end

  def update_dynamic_field(%{id: id, fixed: fixed} = params) do
    if check_business(params) do
      params = Map.merge(params, %{fixed: string_to_map(fixed)})

      case Dynamics.get_dynamic_field_by_id(id) do
        [] -> {:error, @dynamic_field_error}
        [field] -> Dynamics.update_dynamic_field(field, params)
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @dynamic_field_error, __ENV__.line)
  end

  def update_dynamic_field(%{id: id} = params) do
    if check_business(params) do
      case Dynamics.get_dynamic_field_by_id(id) do
        [] -> {:error, @dynamic_field_error}
        [field] -> Dynamics.update_dynamic_field(field, params)
        _ -> {:error, @default_error}
      end
    else
      {:error, @common_error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @dynamic_field_error, __ENV__.line)
  end

  def delete_dynamic_field(%{id: id}) do
    case Dynamics.get_dynamic_field(id) do
      nil -> {:error, @dynamic_field_error}
      %{} = group -> Dynamics.delete_dynamic_field(group)
      _ -> {:error, @default_error}
    end
  end

  def create_dynamic_screen(params) do
    if check_business(params) do
      with {:ok, _last, all} <- DynamicHelper.create_dynamic_screen(params),
           %{dynamic_screen: data} <- all do
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, @common_error}
    end
  end

  def update_dynamic_screen(params) do
    if check_business(params) do
      with {:ok, _last, all} <- DynamicHelper.update_dynamic_screen(params),
           %{dynamic_screen: data} <- all do
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, @common_error}
    end
  end

  def delete_dynamic_screen(params) do
    with {:ok, _last, all} <- DynamicHelper.delete_dynamic_screen(params),
         %{dynamic_screen: data, dynamic_screen_groups: _screen_groups} <- all do
      #      dynamic screen groups is a list
      #      data = Map.merge(data,
      #        %{dynamic_group_order: screen_group.dynamic_group_order,
      #          dynamic_screen: Dynamics.get_dynamic_screen(screen_group.dynamic_screen_id)})
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  end

  def create_dynamic_group(params) do
    if check_business(params) do
      with {:ok, _last, all} <- DynamicHelper.create_dynamic_group(params),
           %{dynamic_group: data} <- all do
        data =
          Map.merge(
            data,
            %{
              dynamic_group_order: params.dynamic_group_order,
              dynamic_screen: Dynamics.get_dynamic_screen(params.dynamic_screen_id)
            }
          )

        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, @common_error}
    end
  end

  def update_dynamic_group(params) do
    if check_business(params) do
      with {:ok, _last, all} <- DynamicHelper.update_dynamic_group(params),
           %{dynamic_group: data} <- all do
        data =
          Map.merge(
            data,
            %{
              dynamic_group_order: params.dynamic_group_order,
              dynamic_screen: Dynamics.get_dynamic_screen(params.dynamic_screen_id)
            }
          )

        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, @common_error}
    end
  end

  def delete_dynamic_group(params) do
    with {:ok, _last, all} <- DynamicHelper.delete_dynamic_group(params),
         %{dynamic_group: data, dynamic_screen_groups: _screen_groups} <- all do
      #      dynamic screen groups is a list
      #      data = Map.merge(data,
      #        %{dynamic_group_order: screen_group.dynamic_group_order,
      #          dynamic_screen: Dynamics.get_dynamic_screen(screen_group.dynamic_screen_id)})
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  end

  def attach_existing_dynamic_group(
        %{dynamic_group_id: group_id, dynamic_screen_id: screen_id} = params
      ) do
    case Dynamics.get_dynamic_screen_group(group_id, screen_id) do
      [] -> Dynamics.create_dynamic_screen_group(params)
      _ -> {:error, ["Dynamic Group already attached to the Screen"]}
    end
  end

  def create_dynamic_field_tag(input) do
    if owner_or_manager_validity(input) do
      case Dynamics.create_dynamic_field_tag(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't insert"], __ENV__.line)
  end

  def get_dynamic_field_tag(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_tag(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_tag -> {:ok, dynamic_field_tag}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_dynamic_field_tag(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_tag(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_tag -> Dynamics.update_dynamic_field_tag(dynamic_field_tag, input)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_dynamic_field_tag(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_tag(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_tag -> Dynamics.delete_dynamic_field_tag(dynamic_field_tag)
        _ -> {:error, @default_error}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def create_dynamic_field_type(input) do
    if owner_or_manager_validity(input) do
      case Dynamics.create_dynamic_field_type(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't insert"], __ENV__.line)
  end

  def get_dynamic_field_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_type(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_type -> {:ok, dynamic_field_type}
        _ -> {:error, @default_error}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't retrieve"], __ENV__.line)
  end

  def update_dynamic_field_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_type(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_type -> Dynamics.update_dynamic_field_type(dynamic_field_type, input)
        _ -> {:error, @default_error}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't update"], __ENV__.line)
  end

  def delete_dynamic_field_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Dynamics.get_dynamic_field_type(id) do
        nil -> {:error, @dynamic_field_error}
        %{} = dynamic_field_type -> Dynamics.delete_dynamic_field_type(dynamic_field_type)
        _ -> {:error, @default_error}
      end
    else
      {:error, ["access denied"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong, can't delete"], __ENV__.line)
  end

  def check_business(%{user_id: user_id, business_id: business_id}) do
    case BSP.get_business_by_user_id(user_id) do
      [] ->
        false

      businesses ->
        business_ids = Enum.map(businesses, & &1.id)

        if business_id in business_ids do
          true
        else
          false
        end
    end
  end

  def check_business(_params) do
    true
  end
end
