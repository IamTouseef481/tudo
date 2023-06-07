defmodule CoreWeb.GraphQL.Resolvers.MetaResolver do
  @moduledoc false
  alias Core.MetaData

  def list_meta_bsp(_, _, _) do
    {:ok, MetaData.list_meta_bsp()}
  end

  def list_meta_cmr(_, _, _) do
    {:ok, MetaData.list_meta_cmr()}
  end

  def get_bsp_meta(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case MetaData.get_meta_bsp_by(input) do
      [] -> {:error, ["Service Provider meta doesn't exist!"]}
      meta -> {:ok, meta}
    end
  end

  def delete_bsp_meta(_, %{input: %{id: id}}, _) do
    case MetaData.get_meta_bsp(id) do
      nil -> {:error, ["Service Provider meta doesn't exist!"]}
      meta -> MetaData.delete_meta_bsp(meta)
    end
  end

  def get_cmr_meta(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case MetaData.get_meta_cmr_by(input) do
      [] -> {:error, ["cmr meta doesn't exist!"]}
      meta -> {:ok, meta}
    end
  end

  def delete_cmr_meta(_, %{input: %{id: id}}, _) do
    case MetaData.get_meta_cmr(id) do
      nil -> {:error, ["cmr meta doesn't exist!"]}
      meta -> MetaData.delete_meta_cmr(meta)
    end
  end
end
