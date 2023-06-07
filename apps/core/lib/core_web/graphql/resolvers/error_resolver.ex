defmodule CoreWeb.GraphQL.Resolvers.ErrorResolver do
  @moduledoc false
  alias Core.Errors

  def list_dart_error(_, _, _) do
    {:ok, Errors.list_dart_errors()}
  end

  def create_dart_error(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case Errors.create_dart_error(input) do
      {:ok, data} ->
        {:ok, Map.merge(data, %{error_time: data.inserted_at})}

      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def get_dart_error(_, %{input: %{id: id}}, %{context: %{current_user: _current_user}}) do
    case Errors.get_dart_error(id) do
      nil -> {:error, ["no error found"]}
      %{} = data -> {:ok, Map.merge(data, %{error_time: data.inserted_at})}
    end
  end

  def update_dart_error(_, %{input: %{id: id} = input}, %{context: %{current_user: _current_user}}) do
    case Errors.get_dart_error(id) do
      nil ->
        {:error, ["no error found"]}

      %{} = data ->
        case Errors.update_dart_error(data, input) do
          {:ok, data} -> {:ok, Map.merge(data, %{error_time: data.inserted_at})}
          {:error, error} -> {:error, error}
        end
    end
  end

  def delete_dart_error(_, %{input: %{id: id}}, %{context: %{current_user: _current_user}}) do
    case Errors.get_dart_error(id) do
      nil ->
        {:error, ["no error found"]}

      %{} = error ->
        case Errors.delete_dart_error(error) do
          {:ok, data} -> {:ok, Map.merge(data, %{error_time: data.inserted_at})}
          {:error, error} -> {:error, error}
        end
    end
  end
end
