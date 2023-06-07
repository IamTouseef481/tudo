defmodule CoreWeb.Controllers.TaxController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Taxes

  def create_tax(input) do
    if CoreWeb.Controllers.DynamicController.check_business(input) do
      case Taxes.create_tax(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["that business doesn't belong to you!"]}
    end
  end

  def get_taxes_by_business(input) do
    if CoreWeb.Controllers.DynamicController.check_business(input) do
      case Taxes.get_taxes_by(input) do
        [] -> {:error, ["no tax added to your business"]}
        taxes -> {:ok, taxes}
      end
    else
      {:error, ["that business doesn't belong to you!"]}
    end
  end

  def update_tax(%{id: id} = input) do
    if CoreWeb.Controllers.DynamicController.check_business(input) do
      case Taxes.get_tax(id) do
        nil -> {:error, ["tax doesn't exist"]}
        %{} = tax -> Taxes.update_tax(tax, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["that business doesn't belong to you!"]}
    end
  end

  def delete_tax(%{id: id} = input) do
    if CoreWeb.Controllers.DynamicController.check_business(input) do
      case Taxes.get_tax(id) do
        nil -> {:error, ["tax doesn't exist"]}
        %{} = tax -> Taxes.delete_tax(tax)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["that business doesn't belong to you!"]}
    end
  end
end
