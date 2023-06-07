defmodule CoreWeb.Controllers.OrderController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Helpers.OrderHelper
  alias Core.Products
  # @default_error ["unexpected error occurred!"]

  def create_order(input) do
    with %{} = delivery_time <-
           default_est_delivery_time(input),
         {:ok, _, %{order: order, create_order_items: create_order_items, quotes: quotes}} <-
           OrderHelper.create_order(Map.merge(input, delivery_time)) do
      {:ok, Map.merge(order, %{order_items: create_order_items, quotes: quotes})}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create Order"],
        __ENV__.line
      )
  end

  def update_order(input) do
    with {:ok, _, %{update_order: order}} <-
           OrderHelper.update_order(input) do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't update Order"],
        __ENV__.line
      )
  end

  def get_order(input) do
    with {:ok, _, %{order: order}} <-
           OrderHelper.get_order(input) do
      {:ok, order}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't update Order"],
        __ENV__.line
      )
  end

  def default_est_delivery_time(%{product_detail: product_detail}) do
    result =
      Enum.reduce_while(product_detail, %{est_delivery_sec: [], description: []}, fn %{
                                                                                       product_id:
                                                                                         id
                                                                                     },
                                                                                     acc ->
        case Products.get_product(id) do
          nil ->
            {:halt, {:error, ["Unable to find product"]}}

          %{category_item_id: category_item_id, description: description} ->
            %{est_delivery_sec: est_delivery_sec} =
              Products.get_product_category_item(category_item_id)

            description = acc.description |> List.insert_at(-1, description)

            if est_delivery_sec in [nil, ""] do
              {:cont, acc}
            else
              est_delivery_sec =
                acc.est_delivery_sec
                |> List.insert_at(-1, est_delivery_sec |> String.to_integer())

              acc = %{est_delivery_sec: est_delivery_sec, description: description}
              {:cont, acc}
            end
        end
      end)

    case result do
      {:error, error} ->
        {:error, error}

      %{est_delivery_sec: est_delivery_sec, description: description} ->
        description = Enum.join(description, ", ")

        if est_delivery_sec == [] do
          %{est_delivery_sec: "", description: description}
        else
          est_delivery_sec = to_string(Enum.sum(est_delivery_sec))
          %{est_delivery_sec: est_delivery_sec, description: description}
        end
    end
  end
end
