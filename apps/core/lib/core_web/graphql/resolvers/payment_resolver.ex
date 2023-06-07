defmodule CoreWeb.GraphQL.Resolvers.PaymentResolver do
  @moduledoc false
  alias Core.{BSP, Payments}
  alias CoreWeb.Controllers.{EarningController, PaymentController}
  alias CoreWeb.GraphQL.Resolvers.CashfreeResolver, as: CR

  #  def job_statuses(_, _, _) do
  #    {:ok, Core.Jobs.list_job_statuses()}
  #  end
  #
  #  def job_categories(_, _, _) do
  #    {:ok, Core.Jobs.list_job_categories()}
  #  end
  def dispute_categories(_, _, _) do
    {:ok, Payments.list_dispute_categories()}
  end

  def dispute_statuses(_, _, _) do
    {:ok, Payments.list_dispute_statuses()}
  end

  def payment_methods(_, _, _) do
    {:ok, Payments.list_payment_methods()}
  end

  def get_payment(_, %{input: %{payment_id: payment_id}}, %{
        context: %{current_user: _current_user}
      }) do
    case Payments.get_payment(payment_id) do
      %{payment_purpose: _payment_purpose} = payment ->
        [payment] = EarningController.preload_invoice_job_and_cash_payment([payment])
        {:ok, payment}

      _ ->
        {:error, ["Payment does not exists"]}
    end
  end

  def get_token(_, _, %{context: %{current_user: current_user}}) do
    case Braintree.ClientToken.generate() do
      {:ok, token} -> Payments.create_brain_tree_tokens(%{token: token, user_id: current_user.id})
      {:error, error} -> {:error, error}
    end
  end

  # get customer
  def get_brain_tree_customer(_, _, %{context: %{current_user: current_user}}) do
    user_id = current_user.id

    case PaymentController.get_brain_tree_customer(%{user_id: user_id}) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # create customer
  def create_brain_tree_customer(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.create_brain_tree_customer(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # Update customer
  def update_brain_tree_customer(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_brain_tree_customer(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # Delete customer
  def delete_brain_tree_customer(_, _, %{context: %{current_user: current_user}}) do
    input = %{user_id: current_user.id}

    case PaymentController.delete_brain_tree_customer(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get payment method
  def get_brain_tree_payment_method(_, %{input: %{token: token}}, %{
        context: %{current_user: current_user}
      }) do
    user_id = current_user.id

    case PaymentController.get_brain_tree_payment_method(%{user_id: user_id, token: token}) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get all payment methods of user
  def get_brain_tree_payment_methods_by_user(_, _, %{context: %{current_user: current_user}}) do
    case PaymentController.get_brain_tree_payment_methods_by_user(%{user_id: current_user.id}) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # create payment_method
  def create_brain_tree_payment_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.create_brain_tree_payment_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # update payment_method
  def update_brain_tree_payment_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_brain_tree_payment_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # delete payment_method
  def delete_brain_tree_payment_method(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.delete_brain_tree_payment_method(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get donation
  def get_donations(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    #    input = Map.merge(input, %{user_id: current_user.id})
    case PaymentController.get_donations(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  rescue
    _ -> {:error, ["share_location_with_user"]}
  end

  # get transaction
  def get_brain_tree_transaction(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_brain_tree_transaction(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get transaction by
  def get_brain_tree_transaction_by(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_brain_tree_transaction_by(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # create brain tree transaction
  def create_brain_tree_transaction(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case CR.is_payment_on_behalf_cmr(input, current_user) do
      {:error, _} = error ->
        error

      %{user: %{id: id}} = params ->
        create_brain_tree_transaction(Map.merge(params, %{user_id: id}))
    end
  end

  def create_brain_tree_transaction(%{country_id: country_id} = input) do
    case Core.Regions.get_countries(country_id) do
      nil ->
        {:error, ["user's country id doesn't exist"]}

      %{} ->
        case PaymentController.create_brain_tree_transaction(input) do
          {:ok, data} -> {:ok, data}
          {:error, changeset} -> {:error, changeset}
        end

      _ ->
        {:error, ["Error in retriving User's Country ID!"]}
    end
  end

  # create Brain tree subscription
  def create_brain_tree_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case Core.Regions.get_countries(current_user.country_id) do
      nil ->
        {:error, ["user's country id doesn't exist"]}

      %{} ->
        input =
          Map.merge(input, %{
            user_id: current_user.id,
            country_id: current_user.country_id,
            user: current_user
          })

        case PaymentController.create_brain_tree_subscription(input) do
          {:ok, data} -> {:ok, data}
          {:error, changeset} -> {:error, changeset}
        end

      _ ->
        {:error, ["Error in retriving User's Country ID!"]}
    end
  end

  # create promotion price
  def create_promotion_price(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case Core.Regions.get_countries(current_user.country_id) do
      nil ->
        {:error, ["user's country id doesn't exist"]}

      %{} ->
        Map.merge(input, %{user_id: current_user.id, country_id: current_user.country_id})
        |> PaymentController.create_promotion_price_from_subscription_rules()

      _ ->
        {:error, ["Error in retriving User's Country ID!"]}
    end
  end

  # update promotion price
  def update_promotion_price(_, %{input: %{id: id} = input}, _) do
    case Payments.get_promotion_purchase_price(id) do
      nil -> {:error, ["Promotion purchase Price missing, try again later!"]}
      %{} = price -> PaymentController.update_promotion_price(price, input)
    end
  end

  # get promotion price
  def get_promotion_price(_, %{input: %{id: id}}, _) do
    case Payments.get_promotion_purchase_price(id) do
      nil -> {:error, ["Promotion purchase Price missing, try again later!"]}
      %{} = price -> {:ok, price}
      _ -> {:error, ["something went wrong"]}
    end
  end

  # delete promotion price
  def delete_promotion_price(_, %{input: %{id: id}}, _) do
    case Payments.get_promotion_purchase_price(id) do
      nil -> {:error, ["Promotion purchase Price missing, try again later!"]}
      %{} = price -> PaymentController.delete_promotion_price(price)
    end
  end

  # get subscription rules by package id
  def get_subscription_bsp_rules_by_slug(_, %{input: input}, %{
        context: %{current_user: _current_user}
      }) do
    case PaymentController.get_subscription_bsp_rules_by_slug(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get all subscription rules for country
  def get_subscription_bsp_rules(_, %{input: %{country_id: country_id}}, _) do
    {:ok, Payments.get_subscription_bsp_rule_by_country(country_id)}
  end

  # create subscription rules
  def create_subscription_bsp_rules(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case PaymentController.create_subscription_bsp_rules(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # update subscription rules
  def update_subscription_bsp_rules(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case PaymentController.update_subscription_bsp_rules(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # delete subscription rules by package id
  def delete_subscription_bsp_rules(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case PaymentController.delete_subscription_bsp_rules(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get Brain tree subscription
  def get_brain_tree_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_brain_tree_subscription(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get Brain tree subscription by
  def get_brain_tree_subscription_by(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_brain_tree_subscription_by(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # Brain tree subscription retry charge
  def retry_charge_brain_tree_subscription(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    %{country_id: country_id} = Core.Accounts.get_user!(current_user.id)
    input = Map.merge(input, %{user_id: current_user.id, country_id: country_id})

    case PaymentController.retry_charge_brain_tree_subscription(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # update Brain tree subscription
  def update_brain_tree_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_brain_tree_subscription(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # cancel Brain tree subscription
  def cancel_brain_tree_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.cancel_brain_tree_subscription(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get cmr paid payments
  def get_cmr_paid_payments(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EarningController.get_cmr_paid_payments(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_cmr_paid_payments(_, _, %{context: %{current_user: current_user}}) do
    input = %{user_id: current_user.id}

    case EarningController.get_cmr_paid_payments(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get bsp paid payments
  def get_bsp_paid_payments(_, %{input: %{branch_id: branch_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    case BSP.get_branch!(branch_id) do
      %{status_id: "confirmed"} ->
        input = Map.merge(input, %{user_id: current_user.id})

        case EarningController.get_bsp_paid_payments(input) do
          {:ok, data} -> {:ok, data}
          {:error, changeset} -> {:error, changeset}
        end

      %{status_id: _} ->
        {:error, ["branch is not approved"]}

      _ ->
        {:error, ["unexpected error occurred"]}
    end
  end

  def get_bsp_paid_payments(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EarningController.get_bsp_paid_payments(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_bsp_paid_payments(_, _, _) do
    {:error, ["Business or Branch ID must present in params"]}
  end

  # get bsp earning
  def get_bsp_earning(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case EarningController.get_bsp_earning(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get tudo earning
  #  def get_tudo_earning(_, %{input: input}, %{context: %{current_user: _current_user}}) do
  #    case EarningController.get_tudo_earning(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #    end
  #  end
  def get_tudo_earning(_, _, %{context: %{current_user: _current_user}}) do
    case EarningController.get_tudo_earning() do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # refund transaction
  def refund_brain_tree_transaction(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.refund_brain_tree_transaction(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # get brain tree merchant account
  def get_brain_tree_merchant_account(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_brain_tree_merchant_account(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  # create brain tree merchant account
  def create_brain_tree_merchant_account(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.create_brain_tree_merchant_account(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  # update brain tree merchant account
  def update_brain_tree_merchant_account(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_brain_tree_merchant_account(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_dispute_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.create_dispute_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_dispute_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_dispute_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def update_dispute_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_dispute_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_dispute_category(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.delete_dispute_category(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_dispute_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.create_dispute_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_dispute_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.get_dispute_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  def update_dispute_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.update_dispute_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_dispute_status(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case PaymentController.delete_dispute_status(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
