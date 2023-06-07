defmodule CoreWeb.Controllers.ProductController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Helpers.ProductHelper
  # @default_error ["unexpected error occurred!"]

  def create_product(input) do
    with {:ok, _, %{create_product: product, inventory: inventory}} <-
           ProductHelper.create_product(input) do
      {:ok, Map.put(product, :inventory, inventory)}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create Product"],
        __ENV__.line
      )
  end

  def update_product(input) do
    with {:ok, _, %{update_product: product}} <-
           ProductHelper.update_product(input) do
      {:ok, product}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't update Product"],
        __ENV__.line
      )
  end

  def delete_product(input) do
    with {:ok, _, %{delete_product: product}} <-
           ProductHelper.delete_product(input) do
      {:ok, product}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't delete  Product"],
        __ENV__.line
      )
  end
end
