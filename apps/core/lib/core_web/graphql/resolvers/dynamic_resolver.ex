defmodule CoreWeb.GraphQL.Resolvers.DynamicResolver do
  @moduledoc false
  alias Core.Dynamics
  alias CoreWeb.Controllers.DynamicController

  def get_dynamic_screens_by(_, %{input: input}, _) do
    case Dynamics.get_dynamic_screens_by(input) do
      {:error, error} -> {:error, error}
      [nil] -> {:ok, []}
      data -> {:ok, data}
    end
  end

  def dynamic_field_tags(_, _, _) do
    {:ok, Dynamics.list_dynamic_fields_tags()}
  end

  def dynamic_field_types(_, _, _) do
    {:ok, Dynamics.list_dynamic_field_types()}
  end

  def get_dynamic_groups(_, %{input: input}, _) do
    {:ok, Dynamics.get_dynamic_group(input)}
  end

  def get_dynamic_fields(_, %{input: input}, _) do
    {:ok, Dynamics.get_dynamic_field(input)}
  end

  def create_dynamic_field_tag(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.create_dynamic_field_tag(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def get_dynamic_field_tag(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.get_dynamic_field_tag(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def update_dynamic_field_tag(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.update_dynamic_field_tag(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def delete_dynamic_field_tag(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.delete_dynamic_field_tag(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def create_dynamic_field_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.create_dynamic_field_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def get_dynamic_field_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.get_dynamic_field_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def update_dynamic_field_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.update_dynamic_field_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def delete_dynamic_field_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.delete_dynamic_field_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def create_dynamic_field_value(
        _,
        %{input: %{fixed: fixed, end_point: end_point, query: query} = input},
        _
      ) do
    fixed = CoreWeb.Utils.CommonFunctions.string_to_map(fixed)
    end_point = CoreWeb.Utils.CommonFunctions.string_to_map(end_point)
    query = CoreWeb.Utils.CommonFunctions.string_to_map(query)
    input = Map.merge(input, %{fixed: fixed, end_point: end_point, query: query})

    case Dynamics.create_dynamic_field_value(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_dynamic_field_value(_, %{input: %{id: id}}, _) do
    case Dynamics.get_dynamic_field_value(id) do
      nil -> {:error, ["dynamic field value doesn't exist!"]}
      %{} = dynamic_field_value -> {:ok, dynamic_field_value}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def update_dynamic_field_value(
        _,
        %{input: %{id: id, fixed: fixed, end_point: end_point, query: query} = input},
        _
      ) do
    fixed = CoreWeb.Utils.CommonFunctions.string_to_map(fixed)
    end_point = CoreWeb.Utils.CommonFunctions.string_to_map(end_point)
    query = CoreWeb.Utils.CommonFunctions.string_to_map(query)
    input = Map.merge(input, %{fixed: fixed, end_point: end_point, query: query})

    case Dynamics.get_dynamic_field_value(id) do
      nil -> {:error, ["dynamic field value doesn't exist!"]}
      %{} = dynamic_field_value -> Dynamics.update_dynamic_field_value(dynamic_field_value, input)
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def delete_dynamic_field_value(_, %{input: %{id: id}}, _) do
    case Dynamics.get_dynamic_field_value(id) do
      nil -> {:error, ["dynamic field value doesn't exist!"]}
      %{} = dynamic_field_value -> Dynamics.delete_dynamic_field_value(dynamic_field_value)
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def create_dynamic_screen(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.create_dynamic_screen(input) do
      {:ok, screen} -> {:ok, screen}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def update_dynamic_screen(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.update_dynamic_screen(input) do
      {:ok, screen} -> {:ok, screen}
      {:error, error} -> {:error, error}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def delete_dynamic_screen(_, %{input: %{id: id} = input}, _) do
    input = Map.merge(input, %{dynamic_screen_id: id})

    case DynamicController.delete_dynamic_screen(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def create_dynamic_field(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.create_dynamic_field(input) do
      {:ok, dynamic_field} -> {:ok, dynamic_field}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def update_dynamic_field(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.update_dynamic_field(input) do
      {:ok, dynamic_field} -> {:ok, dynamic_field}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def delete_dynamic_field(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.delete_dynamic_field(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_dynamic_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.create_dynamic_group(input) do
      {:ok, dynamic_group} -> {:ok, dynamic_group}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def update_dynamic_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.update_dynamic_group(input) do
      {:ok, dynamic_group} -> {:ok, dynamic_group}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def delete_dynamic_group(_, %{input: %{id: id} = input}, _) do
    input = Map.merge(input, %{dynamic_group_id: id})

    case DynamicController.delete_dynamic_group(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def attach_existing_dynamic_group(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case DynamicController.attach_existing_dynamic_group(input) do
      {:ok, dynamic_group} -> {:ok, dynamic_group}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end
end
