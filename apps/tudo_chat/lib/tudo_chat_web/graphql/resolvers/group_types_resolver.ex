defmodule TudoChatWeb.GraphQL.Resolvers.GroupTypesResolver do
  @moduledoc false
  use TudoChatWeb.GraphQL, :resolver
  alias TudoChat.Groups

  @default_error ["unexpected error occurred"]

  def group_types(_, _, %{context: _context}) do
    {:ok, Groups.list_group_types()}
  end

  def create_group_type(_, %{input: %{id: id} = input}, _) do
    case Groups.get_group_type(id) do
      nil -> Groups.create_group_type(input)
      %{} -> {:error, ["Chat group status already exist"]}
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_group_type(_, %{input: %{id: id} = input}, _) do
    case Groups.get_group_type(id) do
      nil -> {:error, ["chat group type doesn't exist"]}
      %{} = type -> Groups.update_group_type(type, input)
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def get_group_type(_, %{input: %{id: id}}, _) do
    case Groups.get_group_type(id) do
      nil -> {:error, ["chat group type doesn't exist"]}
      %{} = type -> {:ok, type}
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def delete_group_type(_, %{input: %{id: id}}, _) do
    case Groups.get_group_type(id) do
      nil -> {:error, ["chat group type doesn't exist"]}
      %{} = type -> Groups.delete_group_type(type)
      _ -> [:error, ["something went wrong"]]
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end
end
