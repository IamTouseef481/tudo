defmodule CoreWeb.GraphQL.Resolvers.DropdownResolver do
  @moduledoc false
  alias Core.BSP

  def list_dropdowns(_, _, _) do
    {:ok, BSP.list_dropdowns()}
  end

  def get_dropdowns(_, %{input: %{type: type, country_id: country_id}}, _) do
    case BSP.get_dropdown_by_user_id(type, country_id) do
      [] -> {:ok, []}
      data -> {:ok, data}
    end
  end
end
