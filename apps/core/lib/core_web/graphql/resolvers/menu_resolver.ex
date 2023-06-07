defmodule CoreWeb.GraphQL.Resolvers.MenuResolver do
  @moduledoc false
  alias Core.Menus

  def menus(_, _, _) do
    {:ok, Menus.list_menus()}
  end

  def menu_roles(_, _, %{context: %{current_user: current_user}}) do
    #    role_list = CoreWeb.Utils.CommonFunctions.get_role_list(current_user.acl_role_id)

    menu_roles =
      Menus.list_menu_roles(current_user.acl_role_id)
      |> Enum.map(fn
        %{acl_role: %{parent: parent}} = data ->
          Map.delete(data, :acl_role)
          |> Map.merge(%{acl_role_parent_id: parent})

        data ->
          data
      end)

    {:ok, menu_roles}
  end

  #  def get_employees_by_branch_id _, %{input: %{branch_id: id}}=input, _ do
  #    {:ok, Employees.get_employees_by_branch_id(id)}
  #  end
  #  def get_employees_by_branch_id _, _, _ do
  #    {:ok, %{employees: []}}
  #  end
  #
  #  def create_employee _, %{input: input}, _ do
  #    case CoreWeb.Controllers.EmployeeController.create_employee(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end
  #  def update_employee _, %{input: input}, _ do
  #    case CoreWeb.Controllers.EmployeeController.update_employee(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end
  #  def delete_employee _, %{input: input}, _ do
  #    case CoreWeb.Controllers.EmployeeController.delete_employee(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end

  def raw_binary_to_string(raw) do
    codepoints = String.codepoints(raw)

    _val =
      Enum.reduce(
        codepoints,
        fn w, result ->
          if String.valid?(w) do
            result <> w
          else
            <<parsed::8>> = w
            result <> <<parsed::utf8>>
          end
        end
      )
  end
end
