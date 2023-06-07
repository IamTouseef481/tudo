defmodule CoreWeb.GraphQL.Resolvers.ProductWarrantyResolver do
  use CoreWeb, :core_resolver

  alias CoreWeb.Controllers.ProductWarrantyController
  alias CoreWeb.Utils.CommonFunctions
  # @default_error ["unexpected error occurred"]

  def create_product_warranty(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input =
      Map.merge(input, %{
        user_id: current_user.id,
        status: to_string(input.status),
        warranty_period_unit: to_string(input.warranty_period_unit),
        warranty_type: to_string(input.warranty_type),
        seller_location: CommonFunctions.location_struct(input.seller_location)
      })

    case ProductWarrantyController.create_product_warranty(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def update_product_warranty(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case ProductWarrantyController.update_product_warranty(
           Map.merge(input, %{user_id: current_user.id})
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def delete_product_warranty(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case ProductWarrantyController.delete_product_warranty(
           Map.merge(input, %{user_id: current_user.id})
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def list_product_warranties(_, %{context: %{current_user: %{id: id}}}),
    do: {:ok, Core.Productwarranty.list(id)}

  def product_types(_, %{context: %{current_user: %{id: _id}}}),
    do: {:ok, Core.Productwarranty.list_product_type()}

  def product_manufacturers(_, %{input: input}, %{context: %{current_user: %{id: _id}}}),
    do: {:ok, Core.Productwarranty.list_manufacturer_name(apply_pagination(input))}

  def product_manufacturers(_, %{input: %{search: _search} = input}, %{
        context: %{current_user: %{id: _id}}
      }),
      do: {:ok, Core.Productwarranty.list_manufacturer_name(apply_pagination(input))}

  def apply_pagination(input) do
    cond do
      input[:page_number] == nil and input[:page_size] == nil ->
        %{page_number: 1, page_size: 20}

      input[:page_number] == nil ->
        %{page_number: 1, page_size: input[:page_size]}

      input[:page_size] == nil ->
        %{page_number: input[:page_number], page_size: 20}

      true ->
        input
    end
  end
end
