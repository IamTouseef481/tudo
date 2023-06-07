defmodule CoreWeb.Controllers.PaymentController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{BSP, Payments, PaypalPayments, Promotions}

  alias CoreWeb.Helpers.{
    BtMerchantHelper,
    BtPaymentMethodHelper,
    BtSubscriptionHelper,
    BtTransactionHelper,
    BtWalletHelper
  }

  def get_brain_tree_customer(input) do
    with {:ok, _last, all} <- BtWalletHelper.get_brain_tree_customer(input),
         %{customer: customer, wallet: wallet} <- all do
      {:ok, Map.merge(customer, wallet)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_brain_tree_customer(input) do
    with {:ok, _last, all} <- BtWalletHelper.create_brain_tree_customer(input),
         %{customer: customer, wallet: wallet} <- all do
      {:ok, Map.merge(customer, wallet)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_brain_tree_customer(input) do
    with {:ok, _last, all} <- BtWalletHelper.update_brain_tree_customer(input),
         %{customer: customer, wallet: wallet} <- all do
      {:ok, Map.merge(customer, wallet)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def delete_brain_tree_customer(input) do
    with {:ok, _last, all} <- BtWalletHelper.delete_brain_tree_customer(input),
         %{braintree_customer: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_payment_method(input) do
    with {:ok, _last, all} <- BtPaymentMethodHelper.get_brain_tree_payment_method(input),
         %{bt_payment_method: data, payment_method: local_payment_method} <- all do
      {:ok, Map.merge(local_payment_method, data)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_payment_methods_by_user(input) do
    with {:ok, _last, all} <- BtPaymentMethodHelper.get_brain_tree_payment_methods_by_user(input),
         %{bt_payment_methods: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_brain_tree_payment_method(input) do
    with {:ok, _last, all} <- BtPaymentMethodHelper.create_brain_tree_payment_method(input),
         %{bt_payment_method: data, payment_method: local_payment_method} <- all do
      {:ok, Map.merge(local_payment_method, data)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_brain_tree_payment_method(input) do
    with {:ok, _last, all} <- BtPaymentMethodHelper.update_brain_tree_payment_method(input),
         %{bt_payment_method: data, payment_method: local_payment_method} <- all do
      {:ok, Map.merge(local_payment_method, data)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def delete_brain_tree_payment_method(input) do
    with {:ok, _last, all} <- BtPaymentMethodHelper.delete_brain_tree_payment_method(input),
         %{bt_payment_method: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_transaction(input) do
    with {:ok, _last, all} <- BtTransactionHelper.get_brain_tree_transaction(input),
         %{bt_transaction: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_transaction_by(input) do
    with {:ok, _last, all} <- BtTransactionHelper.get_brain_tree_transaction_by(input),
         %{bt_transactions: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_brain_tree_transaction(%{credit_card: _} = input) do
    with {:ok, data} <- create_transaction_on_behalf_cmr(input) do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_brain_tree_transaction(input) do
    with {:ok, _last, all} <- BtTransactionHelper.create_brain_tree_transaction(input),
         %{bt_transaction: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_transaction_on_behalf_cmr(input) do
    with {:ok, _last, all} <- BtWalletHelper.create_transaction_on_behalf_cmr(input),
         %{proceed_to_transaction: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  # def create_bt_payment_method(%{payment_method: payment_method} = input) do
  #   Map.merge(payment_method, %{user_id: input.user_id})
  #   |> create_brain_tree_payment_method()
  # end

  def refund_brain_tree_transaction(input) do
    with {:ok, _last, all} <- BtTransactionHelper.refund_brain_tree_transaction(input),
         %{bt_transaction: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def create_brain_tree_subscription(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.create_brain_tree_subscription(input),
         %{local_subscription: data, bt_subscription: sub} <- all do
      {:ok, Map.merge(data, sub)}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_subscription(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.get_brain_tree_subscription(input),
         %{bt_subscription: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_subscription_by(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.get_brain_tree_subscription_by(input),
         %{bt_subscriptions: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def retry_charge_brain_tree_subscription(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.retry_charge_brain_tree_subscription(input),
         %{bt_subscriptions: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_brain_tree_subscription(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.update_brain_tree_subscription(input),
         %{bt_subscription: subscription} <- all do
      {:ok, subscription}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def cancel_brain_tree_subscription(input) do
    with {:ok, _last, all} <- BtSubscriptionHelper.cancel_brain_tree_subscription(input),
         %{bt_subscription: subscription} <- all do
      {:ok, subscription}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_brain_tree_merchant_account(input) do
    with {:ok, _last, all} <- BtMerchantHelper.get_brain_tree_merchant_account(input),
         %{bt_merchant_account: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all ->
      all
  end

  def create_brain_tree_merchant_account(input) do
    with {:ok, _last, all} <- BtMerchantHelper.create_brain_tree_merchant_account(input),
         %{merchant_account: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_brain_tree_merchant_account(input) do
    with {:ok, _last, all} <- BtMerchantHelper.update_brain_tree_merchant_account(input),
         %{bt_merchant_account: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def get_donations(input) do
    case Payments.get_donations_by(input) do
      donations -> {:ok, donations}
    end
  end

  def get_subscription_bsp_rules_by_slug(%{slug: slug, country_id: country_id}) do
    case Payments.get_subscription_bsp_rule_by_slug_and_country(slug, country_id) do
      [] ->
        {:error, ["This Service Provider Subscription rule doesn't exist!"]}

      [package] ->
        {:ok, package}

      _packages ->
        {:error,
         [
           "Multiple Service Provider Subscriptions rules available against this package and Country"
         ]}
    end
  end

  def create_subscription_bsp_rules(%{package_id: id, country_id: country_id} = input) do
    case Payments.get_subscription_bsp_rule_by_package_and_country(id, country_id) do
      [] ->
        case Payments.create_subscription_bsp_rule(input) do
          {:ok, package} ->
            {:ok, package}

          {:error, error} ->
            {:error, [error]}

          _ ->
            {:error,
             ["Something went wrong, unable to create Service Provider Subscription rule"]}
        end

      [%{}] ->
        {:error, ["You already have a Subscription rule against provided package id and Country"]}

      _rules ->
        {:error,
         [
           "Multiple Service Provider Subscriptions rules available against this package and Country"
         ]}
    end
  end

  def update_subscription_bsp_rules(%{id: id} = input) do
    case Payments.get_subscription_bsp_rule(id) do
      nil ->
        {:error, ["This Service Provider Subscription rule doesn't exist!"]}

      %{} = package ->
        case Payments.update_subscription_bsp_rule(package, input) do
          {:ok, package} ->
            {:ok, package}

          {:error, error} ->
            {:error, [error]}

          _ ->
            {:error,
             ["Something went wrong, unable to update Service Proficer Subscription rule"]}
        end

      _ ->
        {:error,
         ["Something went wrong, unable to retrieve Subscription rule for Service Provider"]}
    end
  end

  def delete_subscription_bsp_rules(%{id: id}) do
    case Payments.get_subscription_bsp_rule(id) do
      nil ->
        {:error, ["This Service Provider Subscription rule doesn't exist!"]}

      %{} = package ->
        case Payments.delete_subscription_bsp_rule(package) do
          {:ok, package} ->
            {:ok, package}

          {:error, error} ->
            {:error, [error]}

          _ ->
            {:error,
             ["Something went wrong, unable to delete Subscription rule for Service Provider"]}
        end

      _ ->
        {:error,
         ["Something went wrong, unable to retrieve Subscription rule for Service Provider"]}
    end
  end

  def create_promotion_price_from_subscription_rules(
        %{user_id: _user_id, branch_id: branch_id, country_id: country_id} = params
      ) do
    case BSP.get_branch!(branch_id) do
      nil ->
        {:error, ["Business Branch doesn't exist!"]}

      %{status_id: "confirmed", business_id: business_id, location: %{coordinates: {long, lat}}} ->
        params = Map.merge(params, %{business_id: business_id, geo: %{lat: lat, long: long}})

        case PaypalPayments.get_paypal_subscription_by_business(business_id) do
          [] ->
            case PaypalPayments.get_paypal_subscription_plan_by_country_and_slug(
                   "freelancer",
                   country_id
                 ) do
              nil ->
                {:error, ["Free Subscription rule for Service Providers doesn't exist!"]}

              %{} = plan ->
                make_promotion_price_for(plan, params)

              _ ->
                {:error,
                 [
                   "Something went wrong, unable to retrieve Subscription rule for Service Provider"
                 ]}
            end

          [%{} = subscription | _sub] ->
            make_promotion_price_for(subscription, params)
        end

      %{status_id: _} ->
        {:error, ["branch is not approved"]}

      _ ->
        {:error, ["unexpected error occurred"]}
    end
  end

  def update_promotion_price(price, input) do
    case Payments.update_promotion_purchase_price(price, input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong, unable to update Subscription pricing"]}
    end
  end

  def delete_promotion_price(price) do
    case Payments.delete_promotion_purchase_price(price) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong, unable to delete Subscription pricing"]}
    end
  end

  def make_promotion_price_for(
        %{
          promotions: %{
            "active" => active,
            "included" => included,
            "unit_price" => price,
            "lot_discount" => discount_percentage
          }
        },
        %{branch_id: branch_id, purchase_new_promotion: true} = params
      ) do
    created_promotions = Promotions.get_promotions_by_branch(branch_id)

    if active and included do
      create_promotion_price(price, discount_percentage, params, created_promotions)
    else
      {:error, ["No available Promotion and not allowed to purchase Promotion"]}
    end
  end

  def make_promotion_price_for(
        %{
          promotions: %{
            "active" => active,
            "included" => included,
            "unit_price" => price,
            "lot_discount" => discount_percentage
          }
        },
        %{branch_id: branch_id, business_id: business_id} = params
      ) do
    available_promotions =
      Promotions.get_available_promotions_by(%{
        branch_id: branch_id,
        radius: params.broadcast_range,
        business_id: business_id
      })
      |> Enum.count()

    created_promotions = Promotions.get_promotions_by_branch(branch_id)

    if available_promotions > 0 do
      {:ok, %{purchase_new_promotion: false}}
    else
      if active and included do
        create_promotion_price(price, discount_percentage, params, created_promotions)
      else
        {:error, ["No available Promotion and not allowed to purchase Promotion"]}
      end
    end
  end

  def create_promotion_price(
        price,
        discount_percentage,
        %{
          broadcast_range: range,
          branch_id: branch_id,
          geo: %{lat: _lat, long: _long},
          slug: slug
        } = params,
        _promotions
      ) do
    range_factor = range / 30
    promotion_cost = range_factor * price

    discounted_price =
      if is_nil(discount_percentage) do
        promotion_cost
      else
        promotion_cost - discount_percentage * promotion_cost / 100
      end

    currency_symbol =
      case params do
        %{currency_symbol: symbol} when symbol !== "" ->
          symbol

        %{branch_id: branch_id} ->
          case Core.Regions.get_country_by_branch(branch_id) do
            [%{currency_symbol: currency_symbol} | _] -> currency_symbol
            _ -> ""
          end

        _ ->
          ""
      end

    price = rounding_value(price)
    promotion_cost = rounding_value(promotion_cost)
    total_discount_percentage = rounding_value(discount_percentage)
    final_cost = rounding_value(discounted_price)

    pps_params =
      Map.merge(params, %{
        base_price: price,
        promotion_cost: promotion_cost,
        discounts: [%{value: discount_percentage, is_percentage: true}],
        discount_percentage: total_discount_percentage,
        slug: slug,
        branch_id: branch_id,
        taxes: [],
        tax_percentage: nil,
        promotion_total_cost: final_cost,
        currency_symbol: currency_symbol
      })

    case Payments.create_promotion_purchase_price(pps_params) do
      {:ok, data} ->
        #        Do not proceed payment if due amount is zero and create available promotion
        if final_cost == 0, do: create_available_promotion_for_zero_payment(data)
        {:ok, Map.merge(data, %{purchase_new_promotion: true})}

      {:error, _data} ->
        {:error, ["Error in creating Promotion purchase price, try again"]}
    end
  end

  def rounding_value(value) do
    if is_float(value), do: Float.round(value, 2), else: value
  end

  def check_max_discount(discounts, promotion_cost, settings) do
    total_discount_percentage =
      Enum.reduce(discounts, 0, fn discount, acc ->
        if discount.is_percentage do
          discount.value + acc
        else
          discount.value * 100 / promotion_cost
        end
      end)

    if settings.max_allowed_discount.allow do
      if settings.max_allowed_discount.is_percentage do
        if total_discount_percentage > settings.max_allowed_discount.max_value do
          settings.max_allowed_discount.max_value
        else
          total_discount_percentage
        end
      else
        discount_allowed_percentage =
          settings.max_allowed_discount.max_value * 100 / promotion_cost

        if total_discount_percentage > discount_allowed_percentage do
          discount_allowed_percentage
        else
          total_discount_percentage
        end
      end
    else
      total_discount_percentage
    end
  end

  def check_max_tax(taxes, promotion_cost, settings) do
    total_tax_percentage =
      Enum.reduce(taxes, 0, fn tax, acc ->
        if tax.is_percentage do
          tax.value + acc
        else
          tax.value * 100 / promotion_cost
        end
      end)

    if settings.max_allowed_tax.allow do
      if settings.max_allowed_tax.is_percentage do
        if total_tax_percentage > settings.max_allowed_tax.max_value do
          settings.max_allowed_tax.max_value
        else
          total_tax_percentage
        end
      else
        tax_allowed_percentage = settings.max_allowed_tax.max_value * 100 / promotion_cost

        if total_tax_percentage > tax_allowed_percentage do
          tax_allowed_percentage
        else
          total_tax_percentage
        end
      end
    else
      total_tax_percentage
    end
  end

  def create_dispute_category(input) do
    if owner_or_manager_validity(input) do
      case Payments.create_dispute_category(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_dispute_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_category(id) do
        nil -> {:error, ["Dispute category doesn't exist!"]}
        %{} = dispute_category -> {:ok, dispute_category}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_dispute_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_category(id) do
        nil -> {:error, ["Dispute category doesn't exist!"]}
        %{} = dispute_category -> Payments.update_dispute_category(dispute_category, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_dispute_category(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_category(id) do
        nil -> {:error, ["Dispute category doesn't exist!"]}
        %{} = dispute_category -> Payments.delete_dispute_category(dispute_category)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_dispute_status(input) do
    if owner_or_manager_validity(input) do
      case Payments.create_dispute_status(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_dispute_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_status(id) do
        nil -> {:error, ["dispute status doesn't exist!"]}
        %{} = dispute_status -> {:ok, dispute_status}
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_dispute_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_status(id) do
        nil -> {:error, ["dispute status doesn't exist!"]}
        %{} = dispute_status -> Payments.update_dispute_status(dispute_status, input)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_dispute_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Payments.get_dispute_status(id) do
        nil -> {:error, ["dispute status doesn't exist!"]}
        %{} = dispute_status -> Payments.delete_dispute_status(dispute_status)
        _ -> {:error, ["unexpected error occurred!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  defp create_available_promotion_for_zero_payment(
         %{
           id: id,
           broadcast_range: range,
           branch_id: branch_id,
           promotion_total_cost: promotion_total_cost
         } = _promotion_purchase_price
       ) do
    expire_at = Timex.shift(DateTime.utc_now(), months: 1)

    params = %{
      promotion_pricing_id: id,
      additional: true,
      broadcast_range: range,
      branch_id: branch_id,
      price: promotion_total_cost,
      begin_at: DateTime.utc_now(),
      expire_at: expire_at,
      active: true
    }

    case Promotions.create_available_promotion(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["available promotion isn't created"]}
    end
  end
end
