defmodule CoreWeb.Workers.AutoExpireProductWarrantyWorker do
  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.Productwarranty

  def perform(id) do
    case Productwarranty.get(id) do
      %{} = product_warranty ->
        Productwarranty.update(product_warranty, %{status: "expired"})

      _ ->
        {:error, "product warranty does not exists"}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["could not auto cancel expire the product warranty"],
        __ENV__.line
      )
  end
end
