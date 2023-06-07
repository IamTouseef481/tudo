defmodule CoreWeb.Helpers.ProductWarrantyHelper do
  @moduledoc false

  use CoreWeb, :core_helper
  alias Core.Productwarranty

  #
  # Main actions
  #

  def create_product_warranty(params) do
    new()
    |> run(:check, &check_wrranty_begin_date/2, &abort/3)
    |> run(:check_manufacturer_name, &check_manufacturer_name/2, &abort/3)
    |> run(:product_warranty, &create_product_warranty/2, &abort/3)
    |> run(:expired_warranty, &auto_expired_warranty/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_product_warranty(params) do
    new()
    |> run(:get_product_warranty, &get_product_warranty/2, &abort/3)
    |> run(:check_cmr, &check_cmr/2, &abort/3)
    |> run(:product_warranty, &update_product_warranty/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_product_warranty(params) do
    new()
    |> run(:get_product_warranty, &get_product_warranty/2, &abort/3)
    |> run(:check_cmr, &check_cmr/2, &abort/3)
    |> run(:product_warranty, &delete_product_warranty/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def check_wrranty_begin_date(_, params) do
    date_time = DateTime.compare(params.warranty_begin_date, params.product_purchase_date)

    cond do
      date_time == :eq -> {:ok, params}
      date_time == :lt -> {:error, "warranty begin date Must be >=  Product Purchase Date"}
      date_time == :gt -> {:ok, params}
    end
  end

  def check_manufacturer_name(_, %{manufacturer_id: id} = params) do
    case Productwarranty.get_manufacturer_by(id) do
      nil -> create_manufacturer(id, params)
      _ -> {:ok, params}
    end
  end

  def create_manufacturer(manufacturer_name, params) do
    manufacturer_id =
      manufacturer_name
      |> String.downcase()
      |> String.replace([" ", "-"], "_")

    case Productwarranty.get_manufacturer_by(manufacturer_id) do
      nil ->
        case Productwarranty.create_manufacturer(%{
               id: manufacturer_id,
               description: manufacturer_name
             }) do
          {:ok, data} -> {:ok, Map.merge(params, %{manufacturer_id: data.id})}
          _ -> {:error, ["Unable to create manufacturer"]}
        end

      _ ->
        {:ok, Map.merge(params, %{manufacturer_id: manufacturer_id})}
    end
  end

  def create_product_warranty(%{check_manufacturer_name: params}, _) do
    case Productwarranty.create(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, "unable to create product warranty"}
    end
  end

  def auto_expired_warranty(%{product_warranty: %{id: id}}, %{
        warranty_end_date: warranty_end_date
      }) do
    Exq.enqueue_at(
      Exq,
      "default",
      warranty_end_date,
      "CoreWeb.Workers.AutoExpireProductWarrantyWorker",
      [id]
    )
  end

  def get_product_warranty(_, %{id: id}) do
    case Productwarranty.get(id) do
      nil -> {:error, "product warranty against this id does not exist"}
      data -> {:ok, data}
    end
  end

  def check_cmr(%{get_product_warranty: %{user_id: user_id}}, %{user_id: current_user_id}) do
    if current_user_id == user_id,
      do: {:ok, "valid"},
      else: {:error, "This product warranty does not bleongs to you"}
  end

  def update_product_warranty(%{get_product_warranty: product_warranty}, params) do
    case Productwarranty.update(product_warranty, Map.drop(params, [:id])) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, "unable to update product warranty"}
    end
  end

  def delete_product_warranty(%{get_product_warranty: product_warranty}, _params) do
    case Productwarranty.delete(product_warranty) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, "unable to delete product warranty"}
    end
  end
end
