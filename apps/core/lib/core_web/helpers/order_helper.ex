defmodule CoreWeb.Helpers.OrderHelper do
  @moduledoc false

  use CoreWeb, :core_helper
  import CoreWeb.Endpoint, only: [broadcast: 3]
  alias Core.{Orders, Warehouses, MetaData, Products}
  alias Core.Schemas.Inventory
  alias Core.Employees
  # alias CoreWeb.Controllers.InvoiceController
  alias CoreWeb.Helpers.InvoiceHelper
  alias CoreWeb.Controllers.PaypalPaymentController

  #
  # Main actions
  #

  def create_order(params) do
    new()
    |> run(:order, &create_order/2, &abort/3)
    |> run(:create_order_items, &create_order_items/2, &abort/3)
    |> run(:branch_of_chat_group, &get_branch_of_chat_group/2, &abort/3)
    |> run(:branch_of_product, &get_branch_of_product/2, &abort/3)
    |> run(:check_chat_group_branch_and_product, &check_chat_group_branch_and_product/2, &abort/3)
    |> run(:product_owner, &get_product_owner/2, &abort/3)
    |> run(:create_order_socket, &create_order_socket/2, &abort/3)
    # |> run(:cmr_meta, &update_cmr_meta/2, &abort/3)
    # |> run(:create_order_bsp_meta, &create_order_bsp_meta/2, &abort/3)
    |> run(:create_order_history, &create_order_history/2, &abort/3)
    |> run(:quotes, &create_quotes/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_order(params) do
    new()
    |> run(:order, &is_order_exist/2, &abort/3)
    |> run(:product_owner, &get_product_owner/2, &abort/3)
    |> run(:verify_user_role, &verify_user_role/2, &abort/3)
    |> run(:verify_status, &verify_status/2, &abort/3)
    |> run(:update_order, &update_order/2, &abort/3)
    |> run(:order_items, &get_order_items/2, &abort/3)
    |> run(:update_inventory, &update_inventory/2, &abort/3)
    |> run(:update_order_socket, &update_order_socket/2, &abort/3)
    |> run(:payment_available_for_bsp, &make_payment_available_for_bsp/2, &abort/3)
    |> run(:void_authorize_payment, &void_authorize_payment/2, &abort/3)
    |> run(:capture_authorize_payment, &capture_authorize_payment/2, &abort/3)
    # |> run(:update_order_cmr_meta, &update_order_cmr_meta/2, &abort/3)
    # |> run(:update_order_bsp_meta, &update_order_bsp_meta/2, &abort/3)
    |> run(:create_order_history, &create_order_history/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_order(params) do
    new()
    |> run(:order, &get_order/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_order(_, params) do
    case Orders.create_order(params) do
      {:ok,
       %{
         location_dest: %Geo.Point{coordinates: {long_dest, lat_dest}},
         location_src: %Geo.Point{coordinates: {long_src, lat_src}}
       } = data} ->
        {:ok,
         Map.merge(data, %{
           location_dest: %{long: long_dest, lat: lat_dest},
           location_src: %{long: long_src, lat: lat_src}
         })}

      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} ->
        {:error, "#{k} " <> "#{msg}"}

      _ ->
        {:error, ["Unable to create order"]}
    end
  end

  def create_order_socket(%{order: order, product_owner: product_owner_id}, _),
    do:
      order
      |> Map.from_struct()
      |> Map.drop([:__meta__, :user, :status])
      |> common_response_for_socket(product_owner_id)

  def update_order_socket(%{update_order: order, product_owner: product_owner_id}, _),
    do:
      order
      |> Map.from_struct()
      |> Map.drop([:__meta__, :user, :status])
      |> common_response_for_socket(product_owner_id)

  def common_response_for_socket(order, product_owner_id) do
    {broadcast("order:user_id:#{order.user_id}", "update_order", %{order: order}),
     ["broadcasting to cmr"]}

    {broadcast("order:user_id:#{product_owner_id}", "update_order", %{order: order}),
     ["broadcasting to bsp"]}
  end

  def update_cmr_meta(_, %{user_id: user_id}) do
    case MetaData.get_dashboard_meta_by_user_id(user_id, "dashboard") do
      [] ->
        {:ok, ["valid"]}

      data ->
        {:ok, data}
    end
  end

  def verify_user_role(%{order: %{user_id: order_user_id}}, %{user_id: current_user_id})
      when current_user_id == order_user_id,
      do: {:ok, :cmr}

  def verify_user_role(%{product_owner: product_owner_id}, %{user_id: current_user_id})
      when current_user_id == product_owner_id,
      do: {:ok, :bsp}

  def verify_user_role(_, _), do: {:error, ["You are not eligible to perform this action"]}

  def get_branch_of_chat_group(_, %{chat_group_id: chat_group_id}) do
    case apply(TudoChat.Groups, :get_group, [chat_group_id]) do
      nil ->
        {:error, ["No group found"]}

      %{branch_id: nil} ->
        {:error, ["Branch does not exist against this group"]}

      %{branch_id: branch_id} ->
        {:ok, branch_id}
    end
  end

  def get_branch_of_product(%{order: %{id: id}}, _params) do
    case Orders.get_branch_of_product(id) do
      nil -> {:error, ["This product does not belongs to any branch"]}
      branch_id -> {:ok, branch_id}
    end
  end

  def check_chat_group_branch_and_product(
        %{branch_of_chat_group: branch_of_chat_group, branch_of_product: branch_of_product},
        _
      ) do
    if branch_of_chat_group == branch_of_product do
      {:ok, :valid}
    else
      {:error, ["These products does not belongs to this chat_group"]}
    end
  end

  def get_product_owner(%{order: %{chat_group_id: chat_group_id}}, _) do
    case apply(TudoChat.Groups, :get_group, [chat_group_id]) do
      nil ->
        {:error, ["No group found"]}

      %{branch_id: nil} ->
        {:error, ["Branch does not exist against this group"]}

      %{branch_id: branch_id} ->
        %{user_id: user_id} = Employees.check_branch_owner_or_branch_manager_by(branch_id)
        {:ok, user_id}
    end
  end

  def create_order_items(%{order: %{id: order_id}}, %{product_detail: product_details}) do
    result =
      Enum.reduce_while(product_details, [], fn product_detail, acc ->
        with %Inventory{quantity: quantity} when quantity >= product_detail.quantity <-
               Warehouses.get_inventory_by(%{product_id: product_detail.product_id}),
             {:ok, data} <-
               Orders.create_order_items(Map.merge(product_detail, %{order_id: order_id})) do
          {:cont,
           [
             %{
               id: data.id,
               order_id: data.order_id,
               product_id: data.product_id,
               quantity: data.quantity
             }
             | acc
           ]}
        else
          {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} ->
            {:halt, [{:error, "#{k} " <> "#{product_detail.product_id} " <> "#{msg}"} | acc]}

          _ ->
            {:halt,
             [
               {:error,
                ["Unable to create order items Or may be quanitty is greater then the stock"]}
               | acc
             ]}
        end
      end)

    case result do
      [{:error, error}] -> {:error, error}
      _ -> {:ok, result}
    end
  end

  def is_order_exist(_, %{id: id}) do
    case Orders.get_order(id) do
      nil -> {:error, ["No Record Found"]}
      order -> {:ok, order}
    end
  end

  def verify_status(
        %{
          order: %{status_id: prev_status},
          verify_user_role: user_role
        },
        %{
          status_id: current_status
        }
      ) do
    cond do
      prev_status in ["authorize"] and current_status in ["confirmed", "cancelled"] and
          user_role == :bsp ->
        {:ok, [:valid]}

      prev_status == "confirmed" and current_status in ["started_heading"] and
          user_role == :bsp ->
        {:ok, [:valid]}

      prev_status == "started_heading" and current_status in ["completed"] and
          user_role == :bsp ->
        {:ok, [:valid]}

      prev_status == "pending" and current_status in ["cancelled", "paid"] and user_role == :cmr ->
        {:ok, [:valid]}

      prev_status == "completed" and current_status in ["paid"] and user_role == :cmr ->
        {:ok, [:valid]}

      true ->
        {:error, ["You cannot #{current_status} order, Order is #{prev_status}"]}
    end
  end

  def verify_status(_, _), do: {:ok, []}

  def update_order(%{order: order}, params) do
    params = Map.drop(params, [:id, :user_id])

    case Orders.update_order(order, params) do
      {:ok, data} ->
        {:ok, data}

      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} ->
        {:error, "#{k} " <> "#{msg}"}

      _ ->
        {:error, ["Unable to update order"]}
    end
  end

  def get_order_items(_, %{id: id}) do
    case Orders.get_order_items_by(id) do
      [] -> {:error, ["No order item found"]}
      order_items -> {:ok, order_items}
    end
  end

  def update_inventory(%{order_items: order_items, update_order: %{status_id: "confirmed"}}, _) do
    result =
      Enum.reduce_while(order_items, [], fn order_item, acc ->
        with %Inventory{} = inventory <-
               Warehouses.get_inventory_by(%{product_id: order_item.product_id}),
             {:ok, update_inventory} <-
               Warehouses.update_inventory(inventory, %{
                 quantity: inventory.quantity - order_item.quantity
               }) do
          {:cont, [update_inventory | acc]}
        else
          nil -> {:halt, [{:error, ["No Inventory Found"]}]}
          _ -> {:halt, [{:error, ["Unable to update inventory"]}]}
        end
      end)

    case result do
      [{:error, error}] -> {:error, error}
      _ -> {:ok, result}
    end
  end

  def update_inventory(_, _),
    do: {:ok, ["No Need to update Inventory"]}

  def get_order(_, params), do: {:ok, Orders.get_order_by(params)}

  def create_order_history(
        %{order: order, product_owner: product_owner_id},
        params
      ) do
    params =
      if Map.has_key?(params, :status_id) && params.user_id == product_owner_id do
        %{
          inserted_by: product_owner_id,
          order_id: order.id,
          order_status_id: params.status_id,
          created_at: DateTime.utc_now(),
          user_role: "bsp"
        }
      else
        %{
          inserted_by: params.user_id,
          order_id: order.id,
          order_status_id: params.status_id,
          created_at: DateTime.utc_now(),
          user_role: "cmr"
        }
      end

    case Orders.create_order_history(params) do
      {:ok, data} ->
        {:ok, data}

      _ ->
        {:error, ["Unable to create order history"]}
    end
  end

  def create_quotes(
        %{product_owner: product_owner_id, order: %{id: order_id}, branch_of_product: branch_id},
        %{product_detail: product_detail, user_id: user_id} = params
      ) do
    promotions = []
    taxes = []
    amount = create_amount(product_detail)
    country_id = Core.BSP.get_branch!(branch_id).country_id

    params =
      Map.merge(params, %{
        branch_id: branch_id,
        business_id: nil,
        bsp_id: product_owner_id,
        cmr_id: user_id,
        order_id: order_id,
        is_quote: true,
        country_id: country_id
      })

    case InvoiceHelper.calculate_final_amount_and_create_invoice_or_quotes(
           taxes,
           promotions,
           amount,
           params
         ) do
      {:ok, invoice} ->
        {:ok, Map.drop(invoice, [:__meta__, :__struct__, :order, :business])}

      all ->
        all
    end
  end

  def create_amount(product_detail) do
    Enum.reduce(product_detail, [], fn product, acc ->
      %{sale_price: sale_price} = Products.get_product(product.product_id)

      [
        %{
          unit_price: sale_price,
          quantity: product.quantity,
          discount_eligibility: true,
          tax_eligibility: true
        }
        | acc
      ]
    end)
  end

  def make_payment_available_for_bsp(_, %{status_id: "completed"} = params) do
    with %{id: payment_id} = Core.Payments.get_payment_by_order_id(params.id) do
      release_on = Timex.shift(DateTime.utc_now(), seconds: 5)

      Exq.enqueue_at(
        Exq,
        "default",
        release_on,
        CoreWeb.Workers.PaymentStatusUpdateWorker,
        [payment_id, "active"]
      )
    end
  end

  def make_payment_available_for_bsp(_, _), do: {:ok, [:valid]}

  def capture_authorize_payment(
        %{order: %{authorization_id: auth_id}},
        %{status_id: "completed"} = params
      ) do
    %{transaction_id: transaction_id} = Core.Payments.get_payment_by_order_id(params.id)

    PaypalPaymentController.capture_paypal_order(
      Map.merge(params, %{
        paypal_order_id: transaction_id,
        product_order_id: params.id,
        auth_id: auth_id
      })
    )
  end

  def capture_authorize_payment(_, _), do: {:ok, [:valid]}

  def void_authorize_payment(
        %{order: %{authorization_id: auth_id}, verify_user_role: :bsp},
        %{status_id: "cancelled"}
      ) do
    with {:ok, _last, all} <- CoreWeb.Helpers.PaypalOrderHelper.void_authorize_payment(auth_id),
         %{payment: payment} <- all do
      {:ok, payment}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  end

  def void_authorize_payment(_, _), do: {:ok, [:valid]}
end
