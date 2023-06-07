defmodule CoreWeb.GraphQL.Resolvers.AclResolver do
  @moduledoc false
  alias Core.Employees

  def employees(_, _, _) do
    {:ok, Employees.list_employees()}
  end

  def get_employees_by_branch_id(_, %{input: %{branch_id: id}}, _) do
    {:ok, Employees.get_employees_by_branch_id(id)}
  end

  def get_employees_by_branch_id(_, _, _) do
    {:ok, %{employees: []}}
  end

  def create_employee(_, %{input: input}, _) do
    case CoreWeb.Controllers.EmployeeController.create_employee(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_employee(_, %{input: input}, _) do
    case CoreWeb.Controllers.EmployeeController.update_employee(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_employee(_, %{input: input}, _) do
    case CoreWeb.Controllers.EmployeeController.delete_employee(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
