defmodule CoreWeb.GraphQL.Resolvers.TudoChargesResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.TudoCharges

  def create_tudo_charges(_, %{input: input}, %{
        context: %{current_user: _current_user}
      }) do
    case TudoCharges.create_tudo_charge(input) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      {:error, changeset} -> {:error, changeset}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create tudo charges"], __ENV__.line)
  end

  def update_tudo_charges(_, %{input: %{id: id} = input}, %{
        context: %{current_user: _current_user}
      }) do
    case TudoCharges.get_tudo_charge(id) do
      nil -> {:error, "No record found"}
      data -> TudoCharges.update_tudo_charge(data, Map.drop(input, [:id]))
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to update tudo charges"], __ENV__.line)
  end

  def delete_tudo_charges(_, %{input: %{id: id}}, %{
        context: %{current_user: _current_user}
      }) do
    case TudoCharges.get_tudo_charge(id) do
      nil -> {:error, "No record found"}
      data -> TudoCharges.delete_tudo_charge(data)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to delete tudo charges"], __ENV__.line)
  end

  def get_tudo_charges(_, _) do
    case TudoCharges.list_tudo_charges() do
      [] -> []
      data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get tudo charges"], __ENV__.line)
  end
end
