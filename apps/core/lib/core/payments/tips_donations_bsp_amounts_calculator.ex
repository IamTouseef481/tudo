defmodule Core.Payments.TipsDonationsBspAmountsCalculator do
  @moduledoc false
  import CoreWeb.Utils.{CommonFunctions, Errors}
  alias Core.{BSP, Invoices, Jobs, Payments, PaypalPayments, Promotions, TudoCharges, Orders}
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  require IEx

  def verify_transaction_amount_with_purpose(
        %{invoice_id: invoice_id, job_id: job_id, amount: transaction_amount} = _params
      ) do
    case Invoices.get_invoice(invoice_id) do
      %{final_amount: invoice_amount, job_id: invoiced_job_id} ->
        case Jobs.get_job(job_id) do
          %{id: job_id} ->
            if invoice_amount == transaction_amount do
              if invoiced_job_id == job_id do
                {:ok, ["valid"]}
              else
                {:error, ["invoice does not belongs to this job"]}
              end
            else
              {:error, ["transaction amount couldn't verify with invoice amount!"]}
            end

          _ ->
            {:error, ["Can't get job!"]}
        end

      _ ->
        {:error, ["error in fetching invoice to verify transaction amount"]}
    end
  end

  def verify_transaction_amount_with_purpose(
        %{invoice_id: invoice_id, order_id: order_id, amount: transaction_amount} = _params
      ) do
    case Invoices.get_invoice(invoice_id) do
      %{final_amount: invoice_amount, order_id: invoiced_order_id} ->
        case Orders.get_order(order_id) do
          %{id: order_id} ->
            if invoice_amount == transaction_amount do
              if invoiced_order_id == order_id do
                {:ok, ["valid"]}
              else
                {:error, ["invoice does not belongs to this Order"]}
              end
            else
              {:error, ["transaction amount couldn't verify with invoice amount!"]}
            end

          _ ->
            {:error, ["Can't get job!"]}
        end

      _ ->
        {:error, ["error in fetching invoice to verify transaction amount"]}
    end
  end

  def verify_transaction_amount_with_purpose(
        %{
          promotion_pricing_id: promotion_pricing_id,
          country_id: country_id,
          payment_gateway: "paypal"
        } = params
      ) do
    case Payments.get_promotion_purchase_price(promotion_pricing_id) do
      nil ->
        {:error, ["no record exists for promotion price verification"]}

      %{broadcast_range: range, promotion_total_cost: promotion_total_cost, branch_id: branch_id} =
          _price ->
        if promotion_total_cost == params.amount do
          #          %{business_id: business_id} = BSP.get_branch!(branch_id)
          create_available_promotion(%{
            additional: true,
            broad_cast_range: range,
            branch_id: branch_id,
            price: promotion_total_cost,
            country_id: country_id,
            payment_gateway: "paypal",
            promotion_pricing_id: promotion_pricing_id,
            active: false
          })
        else
          {:error, ["transaction amount couldn't verify"]}
        end

      _ ->
        {:error, ["something went wrong while verifying amount of subscription promotion"]}
    end
  end

  def verify_transaction_amount_with_purpose(
        %{
          subscription_feature_slug: subscription_feature_slug,
          quantity: quantity,
          amount: price,
          payment_method_id: "paypal",
          branch_id: branch_id
        } = params
      ) do
    %{business_id: business_id} = BSP.get_branch!(branch_id)

    case PaypalPayments.get_paypal_subscription_by_business(business_id) do
      [subscription | _] ->
        feature = Map.get(subscription, String.to_atom(subscription_feature_slug))
        additional_lots = Common.getting_total_lots(feature, quantity, 0)

        additional_price =
          Common.applying_discounts(feature, feature["unit_price"], additional_lots, 0)

        if compare_two_floats_with_buffer(price, additional_price) do
          create_available_plan_feature(params)
        else
          {:error, ["transaction amount couldn't verify"]}
        end

      _ ->
        {:error, ["something went wrong while verifying amount of subscription feature"]}
    end
  end

  def verify_transaction_amount_with_purpose(
        %{promotion_pricing_id: promotion_pricing_id, country_id: country_id} = params
      ) do
    case Payments.get_promotion_purchase_price(promotion_pricing_id) do
      nil ->
        {:error, ["no record exists for promotion price verification"]}

      %{broadcast_range: range, promotion_total_cost: promotion_total_cost, branch_id: branch_id} =
          _price ->
        if promotion_total_cost == params.amount do
          %{business_id: business_id} = BSP.get_branch!(branch_id)

          case Payments.get_brain_tree_subscription_by_business(business_id) do
            [] ->
              create_available_promotion(%{
                additional: true,
                broad_cast_range: range,
                branch_id: branch_id,
                rule: "free",
                price: promotion_total_cost,
                active: false,
                country_id: country_id,
                promotion_pricing_id: promotion_pricing_id
              })

            [%{subscription_bsp_rule_id: rule_id}] ->
              %{package_id: rule_id} = Payments.get_subscription_bsp_rule(rule_id)

              create_available_promotion(%{
                additional: true,
                broad_cast_range: range,
                rule: rule_id,
                branch_id: branch_id,
                price: promotion_total_cost,
                active: false,
                country_id: country_id,
                promotion_pricing_id: promotion_pricing_id
              })

            [%{subscription_bsp_rule_id: rule_id} | _subscriptions] ->
              %{package_id: rule_id} = Payments.get_subscription_bsp_rule(rule_id)

              create_available_promotion(%{
                additional: true,
                broad_cast_range: range,
                branch_id: branch_id,
                rule: rule_id,
                price: promotion_total_cost,
                active: false,
                country_id: country_id,
                promotion_pricing_id: promotion_pricing_id
              })
          end
        else
          {:error, ["transaction amount couldn't verify"]}
        end

      _ ->
        {:error, ["something went wrong while verifying amount of subscription promotion"]}
    end
  end

  def verify_transaction_amount_with_purpose(_params) do
    {:ok, ["valid"]}
  end

  def create_available_promotion(%{
        additional: additional,
        broad_cast_range: range,
        branch_id: branch_id,
        price: promotion_price,
        country_id: _country_id,
        payment_gateway: "paypal",
        promotion_pricing_id: promotion_pricing_id,
        active: active
      }) do
    expire_at = Timex.shift(DateTime.utc_now(), months: 1)

    params = %{
      additional: additional,
      price: promotion_price,
      broadcast_range: range,
      branch_id: branch_id,
      begin_at: DateTime.utc_now(),
      expire_at: expire_at,
      promotion_pricing_id: promotion_pricing_id,
      active: active
    }

    case Promotions.create_available_promotion(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["available promotion isn't created"]}
    end
  end

  def create_available_promotion(%{
        additional: additional,
        broad_cast_range: range,
        branch_id: branch_id,
        rule: rule,
        price: promotion_price,
        country_id: country_id,
        promotion_pricing_id: promotion_pricing_id,
        active: active
      }) do
    case Payments.get_subscription_bsp_rule_by_package_and_country(rule, country_id) do
      [] ->
        {:error, ["Subscription rule for Service Provider doesn't exist!"]}

      [%{promotion_validity: val, time_unit: time_unit}] ->
        val = convert_to_months(val, time_unit)
        expire_at = Timex.shift(DateTime.utc_now(), months: val)

        params = %{
          additional: additional,
          price: promotion_price,
          broadcast_range: range,
          branch_id: branch_id,
          begin_at: DateTime.utc_now(),
          expire_at: expire_at,
          promotion_pricing_id: promotion_pricing_id,
          active: active
        }

        case Promotions.create_available_promotion(params) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
          _ -> {:error, ["available promotion isn't created"]}
        end

      _rules ->
        {:error, ["Multiple subscription rules against your Country and Subscription package"]}
    end
  end

  def create_available_promotion(%{
        additional: additional,
        broad_cast_range: range,
        business_id: business_id,
        rule: rule,
        price: promotion_price,
        country_id: country_id
      }) do
    case Payments.get_subscription_bsp_rule_by_package_and_country(rule, country_id) do
      [] ->
        {:error, ["Subscription rule for Service Provider doesn't exist!"]}

      [%{promotion_validity: val, time_unit: time_unit}] ->
        val = convert_to_months(val, time_unit)
        expire_at = Timex.shift(DateTime.utc_now(), months: val)

        params = %{
          additional: additional,
          price: promotion_price,
          broadcast_range: range,
          business_id: business_id,
          begin_at: DateTime.utc_now(),
          expire_at: expire_at
        }

        case Promotions.create_available_promotion(params) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
          _ -> {:error, ["available promotion isn't created"]}
        end

      _rules ->
        {:error, ["Multiple subscription rules against your Country and Subscription package"]}
    end
  end

  def create_available_plan_feature(
        %{payment_method_id: "paypal", amount: price, quantity: quantity} = params
      ) do
    expire_at = Timex.shift(DateTime.utc_now(), months: 1)

    params =
      Map.merge(params, %{
        begin_at: DateTime.utc_now(),
        expire_at: expire_at,
        price: price / quantity
      })

    features =
      Enum.reduce(1..quantity, [], fn _, acc ->
        case Payments.create_available_subscription_feature(params) do
          {:ok, data} -> acc ++ [data]
          _ -> acc
        end
      end)

    {:ok, features}
  end

  def convert_to_months(val, time_unit) do
    cond do
      time_unit in ["month", "months"] -> val
      time_unit in ["year", "years"] -> val * 12
      time_unit in ["day", "days"] -> val / 30
      true -> val
    end
  end

  def calculate_tips_and_donations(%{custom_fields: custom_fields, amount: amount} = params) do
    updated_params =
      case custom_fields do
        %{tip_percentage: tip, donation_slugs: donation_slugs} ->
          tip_amount = tip * amount / 100

          donations =
            Enum.reduce(donation_slugs, %{donations: [], donation_amount: 0}, fn slug, acc ->
              case Payments.get_donation_by_slug(slug) do
                nil ->
                  acc

                %{slug: slug, amount: amount} ->
                  %{
                    donations: ["#{slug}": amount] ++ acc.donations,
                    donation_amount: acc.donation_amount + amount
                  }
              end
            end)

          donation_amount = donations.donation_amount
          bsp_amount = amount + tip_amount
          final_amount = amount + tip_amount + donation_amount
          # converts keyword list into a map
          donations_object = Enum.into(donations.donations, %{})

          custom_fields =
            Map.merge(custom_fields, %{
              invoice_amount: amount,
              bsp_amount: bsp_amount,
              donation_amount: donation_amount,
              tip_amount: tip_amount,
              donations: donations_object
            })

          custom_fields = Map.delete(custom_fields, :donation_slugs)
          Map.merge(params, %{amount: final_amount, custom_fields: custom_fields})

        %{donation_slugs: donation_slugs} ->
          donations =
            Enum.reduce(donation_slugs, %{donations: [], donation_amount: 0}, fn slug, acc ->
              case Payments.get_donation_by_slug(slug) do
                nil ->
                  acc

                %{slug: slug, amount: amount} ->
                  %{
                    donations: ["#{slug}": amount] ++ acc.donations,
                    donation_amount: acc.donation_amount + amount
                  }
              end
            end)

          donation_amount = donations.donation_amount
          final_amount = amount + donation_amount
          # converts keyword list into a map
          donations_object = Enum.into(donations.donations, %{})

          custom_fields =
            Map.merge(custom_fields, %{
              invoice_amount: amount,
              bsp_amount: amount,
              donation_amount: donation_amount,
              donations: donations_object
            })

          custom_fields = Map.delete(custom_fields, :donation_slugs)
          Map.merge(params, %{amount: final_amount, custom_fields: custom_fields})

        %{tip_percentage: tip} ->
          tip_amount = tip * amount / 100
          final_amount = amount + tip_amount

          custom_fields =
            Map.merge(custom_fields, %{
              invoice_amount: amount,
              tip_amount: tip_amount,
              bsp_amount: final_amount
            })

          Map.merge(params, %{amount: final_amount, custom_fields: custom_fields})

        _ ->
          custom_fields = Map.merge(custom_fields, %{invoice_amount: amount, bsp_amount: amount})
          Map.merge(params, %{custom_fields: custom_fields})
      end

    add_other_tudo_charges(updated_params, amount)
  rescue
    exception ->
      logger(__MODULE__, exception, ["Can't add Donation and Gratuity amounts!"], __ENV__.line)
  end

  def add_other_tudo_charges(
        %{amount: updated_amount, custom_fields: custom_fields} = params,
        amount
      ) do
    country_id =
      case params do
        %{country_id: country_id} -> country_id
        _ -> 1
      end

    branch_id =
      cond do
        Map.has_key?(params, :branch_id) ->
          params[:branch_id]

        Map.has_key?(params, :job_id) ->
          case BSP.get_branch_id_by_job_id(params.job_id) do
            %{id: id} -> id
            _ -> nil
          end

        Map.has_key?(params, :order_id) ->
          case Orders.get_branch_of_product(params.order_id) do
            nil -> nil
            branch_id -> branch_id
          end
      end

    booking_charges = calculate_booking_charges(country_id, branch_id, amount, params)

    insurance_fee = calculate_insurance_fee(country_id, branch_id, amount, params)

    updated_amount =
      (updated_amount + booking_charges.tudo_booking_charges +
         insurance_fee.tudo_insurance_charges)
      |> round_off_value()

    additional_charges = Map.merge(booking_charges, insurance_fee)
    updated_custom_fields = Map.merge(custom_fields, additional_charges)
    params = Map.merge(params, %{custom_fields: updated_custom_fields, amount: updated_amount})
    {:ok, params}
  end

  def calculate_booking_charges(_, _, _, %{order_id: _}),
    do: %{tudo_booking_charges: 0, tudo_booking_percentage: 0}

  def calculate_booking_charges(country_id, branch_id, amount, %{job_id: _}) do
    case TudoCharges.get_tudo_charges_by_slug("booking_fee", country_id, branch_id) do
      %{is_percentage: is_percent, value: booking_fee} ->
        booking_fee = round_off_value(booking_fee)

        if is_percent do
          booking_charges = round_off_value(booking_fee * amount / 100)
          %{tudo_booking_charges: booking_charges, tudo_booking_percentage: booking_fee}
        else
          booking_percentage = round_off_value(booking_fee * 100 / amount)
          %{tudo_booking_charges: booking_fee, tudo_booking_percentage: booking_percentage}
        end

      _ ->
        %{tudo_booking_charges: 0, tudo_booking_percentage: 0}
    end
  end

  def calculate_insurance_fee(_, _, _, %{order_id: _}),
    do: %{tudo_insurance_charges: 0, tudo_insurance_percentage: 0}

  def calculate_insurance_fee(country_id, branch_id, amount, %{job_id: _} = params) do
    if params[:get_insured] do
      case TudoCharges.get_tudo_charges_by_slug("insurance_fee", country_id, branch_id) do
        %{is_percentage: is_percent, value: insurance_fee} ->
          insurance_fee = round_off_value(insurance_fee)

          if is_percent do
            insurance_charges = round_off_value(insurance_fee * amount / 100)

            %{
              tudo_insurance_charges: insurance_charges,
              tudo_insurance_percentage: insurance_fee
            }
          else
            insurance_fee = round_off_value(insurance_fee * 100 / amount)
            %{tudo_insurance_charges: insurance_fee, tudo_insurance_percentage: insurance_fee}
          end

        _ ->
          %{tudo_insurance_charges: 0, tudo_insurance_percentage: 0}
      end
    else
      %{tudo_insurance_charges: 0, tudo_insurance_percentage: 0}
    end
  end

  def verify_total_payable_amount(calculated_amount, payable_amount) do
    calculated_amount = round_off_value(calculated_amount)

    if compare_two_floats_with_buffer(calculated_amount, payable_amount) do
      {:ok, ["valid amount"]}
    else
      {:error,
       [
         "Payable amount is not same as Payment Engine Calculated, Backend calculated amount is #{calculated_amount}"
       ]}
    end
  end

  def calculate_donation_tip_and_bsp_amounts_for_local_transaction(
        branch_id,
        amount,
        %{donation_amount: _} = custom_fields,
        business_id,
        country_id
      ) do
    case Payments.get_brain_tree_subscription_by_business(business_id) do
      [] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule_by_package_id("free")

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      [%{subscription_bsp_rule_id: rule_id}] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule(rule_id)

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      [%{subscription_bsp_rule_id: rule_id} | _subscriptions] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule(rule_id)

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      _ ->
        {:error, "Can't get Service Provider Subscriptions"}
    end
  end

  #  for paypal
  def calculate_tip_amount(business_id, country_id) do
    case PaypalPayments.get_paypal_subscription_by_business(business_id) do
      [] ->
        case PaypalPayments.get_paypal_subscription_plan_by_country_and_slug(
               "freelancer",
               country_id
             ) do
          %{gratuity: %{"limit" => tudo_tip}} ->
            if is_binary(tudo_tip) do
              if String.contains?(tudo_tip, "."),
                do: String.to_float(tudo_tip),
                else: String.to_integer(tudo_tip)
            else
              tudo_tip
            end

          _ ->
            100
        end

      [%{subscription_plan_id: plan_id} | _] ->
        case PaypalPayments.get_paypal_subscription_plan(plan_id) do
          %{gratuity: %{"limit" => tudo_tip}} ->
            if is_binary(tudo_tip) do
              if String.contains?(tudo_tip, "."),
                do: String.to_float(tudo_tip),
                else: String.to_integer(tudo_tip)
            else
              tudo_tip
            end

          _ ->
            100
        end
    end
  end

  def calculate_tip_and_bsp_amounts_for_local_transaction(
        branch_id,
        amount,
        custom_fields,
        business_id,
        country_id
      ) do
    case Payments.get_brain_tree_subscription_by_business(business_id) do
      [] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule_by_package_id("free")

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      [%{subscription_bsp_rule_id: rule_id}] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule(rule_id)

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      [%{subscription_bsp_rule_id: rule_id} | _] ->
        %{tudo_portion_of_consumer_tip: tudo_portion_of_customer_tip} =
          Payments.get_subscription_bsp_rule(rule_id)

        calculate_tip_and_bsp_amounts(
          branch_id,
          amount,
          custom_fields,
          country_id,
          "braintree",
          tudo_portion_of_customer_tip
        )

      _ ->
        {:error, "Can't get Service Provider Subscriptions"}
    end
  end

  def calculate_donation_and_bsp_amounts_for_local_transaction(
        branch_id,
        amount,
        custom_fields,
        country_id
      ) do
    calculate_tip_and_bsp_amounts(branch_id, amount, custom_fields, country_id, "braintree")
  end

  #  common calculator for all payment processing engine
  def calculate_tip_and_bsp_amounts(
        branch_id,
        total_transaction_amount,
        custom_fields,
        country_id,
        payment_gateway,
        tudo_tip_percentage \\ 0
      )

  def calculate_tip_and_bsp_amounts(
        branch_id,
        total_transaction_amount,
        %{
          invoice_amount: invoice_amount,
          tudo_insurance_charges: insurance_charges,
          tudo_insurance_percentage: insurance_percentage,
          tudo_booking_charges: booking_charges,
          tudo_booking_percentage: booking_percentage
        } = custom_fields,
        country_id,
        payment_gateway,
        tudo_tip_percentage
      ) do
    commission_percentage = getting_tudo_charges("commission_fee", country_id, branch_id)
    cancellation_percentage = getting_tudo_charges("cancellation_fee", country_id, branch_id)
    govt_fee_percentage = getting_tudo_charges("govt_fee", country_id, branch_id)
    commission_charges = get_tudo_charges("commission_fee", invoice_amount, country_id, branch_id)

    cancellation_charges =
      get_tudo_charges("cancellation_fee", invoice_amount, country_id, branch_id)

    govt_charges = get_tudo_charges("govt_fee", invoice_amount, country_id, branch_id)
    #    tudo_tip_percentage = 50   # just for verification with excel document
    [donations, donation_amount] =
      case custom_fields do
        %{donation_amount: donation_amount, donations: donations} -> [donations, donation_amount]
        _ -> [%{}, 0]
      end

    tip =
      case custom_fields do
        %{tip_amount: tip} -> tip
        _ -> 0
      end

    total_tip_percentage =
      case custom_fields do
        %{tip_percentage: tip} -> tip
        _ -> 0
      end

    tudo_tip_amount = (tudo_tip_percentage * tip / 100) |> round_off_value()
    bsp_tip_amount = tip - tudo_tip_amount

    tudo_total_amount =
      (tudo_tip_amount + commission_charges + booking_charges + insurance_charges)
      |> round_off_value()

    tudo_total_deducted_amount = (tudo_total_amount + donation_amount) |> round_off_value()

    #    brain_tree_fee = if payment_gateway == "braintree" do
    #      get_tudo_charges("braintree_fee", total_transaction_amount, country_id)
    #    else
    #      0
    #    end
    #    paypal_fee = if payment_gateway == "paypal" do
    #      get_tudo_charges("paypal_payment_fee", total_transaction_amount, country_id)
    #    else
    #      0
    #    end
    %{payment_gateway_fee: payment_gateway_fee} =
      gateway_fee_params =
      case payment_gateway do
        "paypal" ->
          get_tudo_payment_gateway_charges(
            "paypal_payment_fee",
            total_transaction_amount,
            country_id,
            branch_id
          )

        "braintree" ->
          get_tudo_payment_gateway_charges(
            "braintree_fee",
            total_transaction_amount,
            country_id,
            branch_id
          )

        _ ->
          %{payment_gateway_fee: 0}
      end

    bsp_invoice_amount = round_off_value(invoice_amount + tip)
    #    _tudo_bank_available_balance = total_transaction_amount - brain_tree_fee
    chargebacks =
      case Payments.get_balance_by_branch(branch_id) do
        %{bsp_pending_balance: balance, tudo_due_amount: tudo_due_amount} ->
          if balance < 0, do: -balance + tudo_due_amount, else: tudo_due_amount

        _ ->
          0
      end

    #    commission charges are excluded from bsp amount as it is not collected form CMR, it's directly deducted from BSP anount
    bsp_excluding = payment_gateway_fee + tudo_tip_amount + govt_charges + commission_charges
    bsp_total_amount = round_off_value(bsp_invoice_amount - bsp_excluding)

    tudo_reserve_amount =
      if payment_gateway in ["cash", "cheque"] do
        0
      else
        if bsp_total_amount - chargebacks < 0, do: 0, else: bsp_total_amount - chargebacks
      end

    Map.merge(
      gateway_fee_params,
      %{
        invoice_amount: invoice_amount,
        bsp_amount: bsp_invoice_amount,
        tudo_booking_charges: booking_charges,
        tudo_commission_charges: commission_charges,
        insurance_amount: insurance_charges,
        insurance_percentage: insurance_percentage,
        donation_amount: donation_amount,
        donations: donations,
        total_tip_amount: tip,
        tudo_booking_percentage: booking_percentage,
        bsp_tip_amount: bsp_tip_amount,
        tudo_tip_amount: tudo_tip_amount,
        tudo_tip_percentage: tudo_tip_percentage,
        bsp_total_amount: bsp_total_amount,
        tudo_total_amount: tudo_total_amount,
        tudo_total_deducted_amount: tudo_total_deducted_amount,
        tudo_reserve_amount: tudo_reserve_amount,
        total_transaction_amount: total_transaction_amount,
        commission_percentage: commission_percentage,
        tip_percentage: total_tip_percentage,
        cancellation_fee: cancellation_charges,
        cancellation_percentage: cancellation_percentage,
        chargebacks: chargebacks,
        govt_fee: govt_charges,
        govt_fee_percentage: govt_fee_percentage
      }
    )
  end

  def calculate_tip_and_bsp_amounts(
        _branch_id,
        _amount,
        _custom_fields,
        _country_id,
        _gateway,
        _tudo_tip_percentage
      ) do
    {:error, ["Params to calculate local transaction are not correct"]}
  end

  def getting_tudo_charges(slug, country_id \\ 1, branch_id \\ nil) do
    case TudoCharges.get_tudo_charges_by_slug(slug, country_id, branch_id) do
      %{value: charges} -> round_off_value(charges)
      _ -> 0
    end
  end

  def get_tudo_charges(slug, amount, country_id \\ 1, branch_id \\ nil) do
    case TudoCharges.get_tudo_charges_by_slug(slug, country_id, branch_id) do
      %{is_percentage: is_percent, value: charges} ->
        if is_percent do
          round_off_value(charges * amount / 100)
        else
          round_off_value(charges)
        end

      _ ->
        0
    end
  end

  def get_tudo_payment_gateway_charges(slug, amount, country_id \\ 1, branch_id \\ nil) do
    case TudoCharges.get_tudo_charges_by_slug(slug, country_id, branch_id) do
      %{is_percentage: is_percent, value: charges} ->
        if is_percent do
          %{
            payment_gateway_fee_percentage: round_off_value(charges),
            payment_gateway_fee: round_off_value(charges * amount / 100)
          }
        else
          %{payment_gateway_fee: round_off_value(charges)}
        end

      _ ->
        %{payment_gateway_fee: 0}
    end
  end

  def creates_local_transaction(
        token,
        transaction_id,
        %{job_id: job_id, invoice_id: invoice_id, currency_symbol: currency_symbol} =
          input_params,
        params,
        "braintree"
      ) do
    branch_id =
      case BSP.get_branch_by_job_id(job_id) do
        %{id: id} -> id
        _ -> nil
      end

    %{business_id: business_id} = BSP.get_branch!(branch_id)

    updated_params =
      case params do
        %{custom_fields: %{donation_amount: _, tip_amount: _} = custom_fields} ->
          calculate_donation_tip_and_bsp_amounts_for_local_transaction(
            branch_id,
            params.amount,
            custom_fields,
            business_id,
            input_params[:country_id]
          )

        %{custom_fields: %{tip_amount: _} = custom_fields} ->
          calculate_tip_and_bsp_amounts_for_local_transaction(
            branch_id,
            params.amount,
            custom_fields,
            business_id,
            input_params[:country_id]
          )

        #        %{custom_fields: %{donation_amount: _}= custom_fields} ->
        #          AMC.calculate_donation_and_bsp_amounts_for_local_transaction(params.amount,
        #          custom_fields, country_id)
        %{custom_fields: custom_fields} ->
          #        including donations as no calculations needed on donations, just to add in table
          calculate_tip_and_bsp_amounts(
            branch_id,
            params.amount,
            custom_fields,
            input_params[:country_id],
            "braintree"
          )
      end

    case updated_params do
      {:error, error} ->
        {:error, error}

      updated_params ->
        updated_params =
          Map.merge(updated_params, %{
            payment_purpose: %{job_id: job_id, invoice_id: invoice_id},
            business_id: business_id,
            branch_id: branch_id,
            transaction_id: transaction_id,
            payment_method_token: token,
            currency_symbol: currency_symbol
          })

        creating_local_transaction(input_params, updated_params, "braintree")
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Error in making params for local payment, try again"],
        __ENV__.line
      )
  end

  def creates_local_transaction(token, transaction_id, input_params, params, payment_method) do
    if payment_method in ["paypal", "cash", "cheque", "cashfree"] do
      creates_gateway_local_transaction(
        token,
        transaction_id,
        input_params,
        params,
        payment_method
      )
    else
      {:error, ["payment mehtod is not correctly defined"]}
    end
  end

  def creates_gateway_local_transaction(
        token,
        transaction_id,
        %{
          job_id: job_id,
          invoice_id: _,
          #          currency_symbol: currency_symbol,
          country_id: _
        } = input_params,
        params,
        payment_gateway
      ) do
    branch_id =
      case BSP.get_branch_by_job_id(job_id) do
        %{id: id} -> id
        _ -> nil
      end

    data =
      case BSP.get_branch_id_by_job_id(job_id) do
        %{id: id} -> id
        _ -> nil
      end

    branch_id = branch_id || data

    %{business_id: business_id} = BSP.get_branch!(branch_id)

    updated_params(
      input_params,
      params,
      payment_gateway,
      business_id,
      branch_id,
      transaction_id,
      token
    )
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Error in making params for local payment, try again"],
        __ENV__.line
      )
  end

  def creates_gateway_local_transaction(
        token,
        transaction_id,
        %{
          order_id: order_id,
          invoice_id: _,
          #          currency_symbol: currency_symbol,
          country_id: _
        } = input_params,
        params,
        payment_gateway
      ) do
    branch_id =
      case Orders.get_branch_of_product(order_id) do
        nil -> nil
        branch_id -> branch_id
      end

    %{business_id: business_id} = BSP.get_branch!(branch_id)

    updated_params(
      input_params,
      params,
      payment_gateway,
      business_id,
      branch_id,
      transaction_id,
      token
    )
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Error in making params for local payment, try again"],
        __ENV__.line
      )
  end

  def updated_params(
        input_params,
        params,
        payment_gateway,
        business_id,
        branch_id,
        transaction_id,
        token
      ) do
    updated_params =
      case params do
        %{custom_fields: %{tip_amount: _} = custom_fields} ->
          tudo_tip = calculate_tip_amount(business_id, input_params[:country_id])

          calculate_tip_and_bsp_amounts(
            branch_id,
            params.amount,
            custom_fields,
            input_params[:country_id],
            payment_gateway,
            tudo_tip
          )

        %{custom_fields: custom_fields} ->
          calculate_tip_and_bsp_amounts(
            branch_id,
            params.amount,
            custom_fields,
            input_params[:country_id],
            payment_gateway
          )
      end

    case updated_params do
      {:error, error} ->
        {:error, error}

      updated_params ->
        updated_params =
          if Map.has_key?(input_params, :currency_symbol) do
            Map.merge(updated_params, %{
              payment_purpose: %{
                job_id: input_params[:job_id],
                invoice_id: input_params[:invoice_id]
              },
              business_id: business_id,
              branch_id: branch_id,
              transaction_id: transaction_id,
              payment_method_token: token,
              currency_symbol: input_params[:currency_symbol]
            })
          else
            Map.merge(updated_params, %{
              payment_purpose: %{
                job_id: input_params[:job_id],
                invoice_id: input_params[:invoice_id]
              },
              business_id: business_id,
              branch_id: branch_id,
              transaction_id: transaction_id,
              payment_method_token: token,
              currency_code: input_params[:currency_code]
            })
          end

        creating_local_transaction(input_params, updated_params, payment_gateway)
    end
  end

  defp creating_local_transaction(
         %{user_id: user_id, payment_method_id: payment_method_id},
         updated_params,
         payment_gateway
       ) do
    cmr_payment_status_id =
      if payment_gateway in ["paypal", "cash", "cheque", "cashfree"],
        do: "pending",
        else: "active"

    params =
      Map.merge(updated_params, %{
        user_id: user_id,
        cmr_payment_status_id: cmr_payment_status_id,
        bsp_payment_status_id: "pending",
        from_cmr: true,
        payment_method_id: payment_method_id,
        paid_at: DateTime.utc_now()
      })

    case Payments.create_payment(params) do
      {:ok, local_payment} ->
        #        availability of paypal transaction is handled on capture order, not on local payment creation(create order),
        #        so in local payment creation it is bypassed
        # if payment_gateway not in ["paypal", "cash", "cheque", "cashfree"],
        #   do: make_payment_available_for_bsp(local_payment.id, input_params.country_id)

        {:ok, local_payment}

      {:error, _} ->
        {:error, ["Something went wrong, unable to create local transaction"]}
    end
  end

  def make_payment_available_for_bsp(payment_id, country_id, branch_id) do
    delay_days =
      case TudoCharges.get_tudo_charges_by_slug("bsp_transfer_delay_days", country_id, branch_id) do
        %{value: delay_days} -> delay_days
        _ -> 0
      end

    delay_days = if is_float(delay_days), do: trunc(delay_days), else: delay_days
    release_on = Timex.shift(DateTime.utc_now(), days: delay_days)
    #        release_on = Timex.shift(DateTime.utc_now, seconds: 90)  #for testing
    Exq.enqueue_at(
      Exq,
      "default",
      release_on,
      CoreWeb.Workers.PaymentStatusUpdateWorker,
      [payment_id, "active"]
    )
  end
end
