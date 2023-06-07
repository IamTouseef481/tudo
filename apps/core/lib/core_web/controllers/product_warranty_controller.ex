defmodule CoreWeb.Controllers.ProductWarrantyController do
  @moduledoc false

  use CoreWeb, :controller

  alias CoreWeb.Helpers.ProductWarrantyHelper
  # @default_error ["unexpected error occurred!"]

  def create_product_warranty(input) do
    with {:ok, input} <- check_wrranty_end_date(input),
         {:ok, _, %{product_warranty: product_warranty}} <-
           ProductWarrantyHelper.create_product_warranty(input) do
      {:ok, product_warranty}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't create the Product Warranty"],
        __ENV__.line
      )
  end

  def check_wrranty_end_date(
        %{warranty_period: period, warranty_period_unit: unit, warranty_begin_date: date_time} =
          input
      ) do
    warranty_end_date =
      cond do
        unit == "days" -> Timex.shift(date_time, days: period)
        unit == "months" -> Timex.shift(date_time, months: period)
        unit == "years" -> Timex.shift(date_time, years: period)
      end

    {:ok, Map.merge(input, %{warranty_end_date: warranty_end_date})}
  end

  def update_product_warranty(input) do
    with {:ok, _, %{product_warranty: product_warranty}} <-
           ProductWarrantyHelper.update_product_warranty(input) do
      {:ok, product_warranty}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't update the Product Warranty"],
        __ENV__.line
      )
  end

  def delete_product_warranty(input) do
    with {:ok, _, %{product_warranty: product_warranty}} <-
           ProductWarrantyHelper.delete_product_warranty(input) do
      {:ok, product_warranty}
    else
      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't delete the Product Warranty"],
        __ENV__.line
      )
  end
end
