defmodule CoreWeb.GraphQL.Resolvers.ProductResolver do
  use CoreWeb, :core_resolver
  alias CoreWeb.Controllers.ProductController
  alias Core.{Products, Regions}

  def create_product(_, %{input: %{branch_id: branch_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = input |> make_params()

    [%{currency_code: currency}] = Regions.get_country_by_branch(branch_id)

    input =
      Map.merge(input, %{
        category_item_id: Atom.to_string(input.category_item_id),
        category_id: Atom.to_string(input.category_id),
        currency: currency,
        user_id: current_user.id
      })

    case ProductController.create_product(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def list_product(_, %{input: input}, _), do: {:ok, Products.list_product(input)}
  def list_product_category(_, _), do: {:ok, Products.list_product_category()}

  def delete_product(_, %{input: %{id: _id} = input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ProductController.delete_product(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def update_product(_, %{input: %{id: _id} = input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case ProductController.update_product(make_params(input)) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def make_params(input) do
    if Map.has_key?(input, :attribute) do
      attribute =
        Enum.map(input.attribute, fn attribute ->
          {:ok, attribute} = Poison.decode(attribute)
          attribute
        end)

      Map.merge(input, %{attribute: attribute})
    else
      input
    end
  end

  def get_country_uom(_, %{branch_id: branch_id}, _) do
    case Regions.get_country_by_branch(branch_id) do
      [] ->
        {:ok, []}

      [country] ->
        %{unit_system: unit_system} = country |> Map.from_struct()
        {:ok, %{unit_system: unit_system}}
    end
  end
end
