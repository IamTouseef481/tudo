defmodule Core.PaypalPayments.SubscriptionHandler do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias CoreWeb.Controllers.PaypalPaymentController
  alias CoreWeb.Utils.CommonFunctions
  alias Core.{Accounts, BSP, PaypalPayments, Promotions}
  alias CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver, as: R

  def updated_subscription_usage(subscription, _annual, features, update_subscription \\ true) do
    updated_all_features =
      Enum.reduce_while(features, %{}, fn
        #      selected features with count is sending to be checked and update
        #      count is sending from function call, so that multiple items can be updated in a single query
        {key, %{features: features, count: count}}, acc ->
          count = if is_nil(count), do: 0, else: count

          case update_feature_usage(features, key, count) do
            {:error, error} -> {:halt, {:error, error}}
            updated_features -> {:cont, Map.merge(acc, updated_features)}
          end

        #      if count is not added in feature object it will be considered as 11
        {key, features}, acc ->
          if update_subscription do
            #          if it is needed to update subscription on any feature usage
            case update_feature_usage(features, key, 1) do
              {:error, error} -> {:halt, {:error, error}}
              updated_features -> {:cont, Map.merge(acc, updated_features)}
            end
          else
            #          if it is needed to just verify subscription limits
            case verify_subscription_data(features, key) do
              {:error, error} -> {:halt, {:error, error}}
              _ -> {:cont, {:ok, subscription}}
            end
          end
      end)

    with %{} <- updated_all_features,
         true <- update_subscription,
         {:ok, subscription} <-
           PaypalPayments.update_paypal_subscription(subscription, updated_all_features) do
      {:ok, subscription}
    else
      false -> {:ok, subscription}
      {:ok, subscription} -> {:ok, subscription}
      {:error, error} -> {:error, error}
    end
  end

  defp update_feature_usage(features, key, count) do
    error_message =
      if key == :employees do
        "#{to_string(key)} can't Invited. Please Upgrade Your Plan"
      else
        "#{to_string(key)} can't Created. Please Upgrade Your Plan"
      end

    updated_feature =
      cond do
        features["remaining_limit"] == "unlimited" or features["remaining_limit"] == "Unlimited" ->
          Map.merge(features, %{"used_limit" => features["used_limit"] + count})

        is_integer(features["monthly_remaining_limit"]) ->
          if features["monthly_remaining_limit"] > 0 do
            Map.merge(features, %{
              "monthly_remaining_limit" => features["monthly_remaining_limit"] - count,
              "monthly_used_limit" => features["monthly_used_limit"] + count
            })
          else
            {:error, [error_message]}
          end

        is_integer(features["annual_remaining_limit"]) ->
          if features["annual_remaining_limit"] > 0 do
            Map.merge(features, %{
              "annual_remaining_limit" => features["annual_remaining_limit"] - count,
              "annual_used_limit" => features["annual_used_limit"] + count
            })
          else
            {:error, [error_message]}
          end

        #      is_integer(features["remaining_limit"]) ->
        #        if features["remaining_limit"] > 0 do
        #          Map.merge(features, %{"remaining_limit" => features["remaining_limit"] - count,
        #            "used_limit" => features["used_limit"] + count})
        #        else
        #          {:error, [error_message]}
        #        end
        is_nil(features["annual_remaining_limit"]) and is_nil(features["monthly_remaining_limit"]) ->
          {:error, [error_message]}

        true ->
          {:error, ["#{to_string(key)} limit can't Verified."]}
      end

    case updated_feature do
      {:error, error} -> {:error, error}
      updated_feature -> Map.put(%{}, key, updated_feature)
    end
  end

  defp verify_subscription_data(features, key) do
    error_message =
      if key == :employees do
        "#{to_string(key)} can't Invited. Please Upgrade Your Plan"
      else
        "#{to_string(key)} can't Created. Please Upgrade Your Plan"
      end

    cond do
      features["remaining_limit"] == "unlimited" or features["remaining_limit"] == "Unlimited" ->
        {:ok, ["valid"]}

      #      is_integer(features["remaining_limit"]) ->
      #        if features["remaining_limit"] > 0, do: {:ok, ["valid"]}, else: {:error, [error_message]}
      is_integer(features["monthly_remaining_limit"]) ->
        if features["monthly_remaining_limit"] > 0,
          do: {:ok, ["valid"]},
          else: {:error, [error_message]}

      is_integer(features["annual_remaining_limit"]) ->
        if features["annual_remaining_limit"] > 0,
          do: {:ok, ["valid"]},
          else: {:error, [error_message]}

      is_nil(features["annual_remaining_limit"]) and is_nil(features["monthly_remaining_limit"]) ->
        {:error, [error_message]}

      true ->
        {:error, ["#{to_string(key)} limit can't Verified."]}
    end
  end

  def creates_paypal_plan(
        name,
        country_id,
        access_token,
        paypal_partner_attribution_id,
        product_id,
        params
      ) do
    amount =
      case params do
        %{monthly_price: monthly_price} -> monthly_price
        %{annual_price: annual_price} -> annual_price / 12
        _ -> 0
      end

    currency_code =
      case Core.Regions.get_countries(country_id) do
        %{currency_code: code} -> code
        _ -> "USD"
      end

    #    product_id = "PROD-95C91318JG477522C" #to be get from DB
    billing_cycles = [
      %{
        total_cycles: 0,
        frequency: %{interval_unit: "MONTH", interval_count: 1},
        tenure_type: "REGULAR",
        sequence: 1,
        pricing_scheme: %{fixed_price: %{value: amount, currency_code: currency_code}}
      }
    ]

    payment_preferences = %{
      auto_bill_outstanding: true,
      setup_fee_failure_action: "CONTINUE",
      payment_failure_threshold: 3
    }

    plan = %{
      name: name,
      product_id: product_id,
      billing_cycles: billing_cycles,
      payment_preferences: payment_preferences
    }

    url = System.get_env("PAYPAL_PLAN_URL")

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer " <> access_token},
      {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id},
      {"PayPal-Request-Id", UUID.uuid1()}
      #      {"PayPal-Auth-Assertion", access_token}
    ]

    body = Poison.encode!(plan)

    case HTTPoison.post(url, body, headers, hackney: [basic_auth: R.auth()]) do
      {:ok, data} ->
        case Poison.decode(data.body) do
          {:error, error, _} ->
            {:error, error}

          {:error, error} ->
            {:error, error}

          {:ok, %{"error_description" => error} = _data} ->
            {:error, error}

          {:ok, %{"message" => _, "details" => [%{"description" => error} | _]} = _data} ->
            {:error, error}

          {:ok, %{"links" => [], "message" => message} = _data} ->
            {:error, [message]}

          {:ok, %{"links" => _links} = data} ->
            {:ok, CommonFunctions.keys_to_atoms(data)}

          _ ->
            {:error, ["No case clause matching"]}
        end

      exception ->
        logger(__MODULE__, exception, ["Unable to create Paypal Plan"], __ENV__.line)
    end
  end

  def make_plan_customized(currency, %{annual: annual} = params, plan) do
    price =
      case plan do
        %{price: price} ->
          price

        %{monthly_price: monthly_price, annual_price: annual_price} ->
          if annual, do: annual_price, else: monthly_price
      end

    months = if annual, do: 12, else: 1

    case params do
      %{cycles_count: cycles_count} ->
        %{
          billing_cycles: [
            %{
              total_cycles: cycles_count,
              frequency: %{interval_unit: "MONTH", interval_count: months},
              pricing_scheme: %{fixed_price: %{value: price, currency_code: currency}},
              sequence: 1
            }
          ]
        }

      _ ->
        %{
          billing_cycles: [
            %{
              frequency: %{interval_unit: "MONTH", interval_count: months},
              pricing_scheme: %{fixed_price: %{value: price, currency_code: currency}},
              sequence: 1
            }
          ]
        }
    end
  end

  def update_plan_usage_information(plan, annual) do
    price =
      case plan do
        %{price: price} ->
          if annual, do: %{annual_pricce: price}, else: %{monthly_price: price}

        _ ->
          if annual,
            do: %{annual_pricce: plan.annual_price},
            else: %{monthly_price: plan.monthly_price}
      end

    plan = Map.from_struct(plan) |> Map.delete(:id) |> Map.merge(price)

    Enum.reduce(plan, plan, fn {key, val}, acc ->
      cond do
        is_struct(val) ->
          acc

        is_map(val) and !Enum.empty?(val) ->
          cond do
            is_nil(val["annual_limit"]) and is_nil(val["monthly_limit"]) and
                (val["limit"] == "unlimited" or val["limit"] == "Unlimited") ->
              updated_object =
                Map.merge(val, %{"remaining_limit" => "unlimited", "used_limit" => 0})

              Map.put(acc, key, updated_object)

            is_nil(val["annual_limit"]) and is_nil(val["monthly_limit"]) and
                not is_nil(val["limit"]) ->
              updated_object = Map.merge(val, %{"remaining_limit" => 0, "used_limit" => 0})
              Map.put(acc, key, updated_object)

            true ->
              if annual do
                used = if is_nil(val["annual_limit"]), do: nil, else: 0

                updated_object =
                  Map.merge(val, %{
                    "annual_remaining_limit" => val["annual_limit"],
                    "annual_used_limit" => used
                  })

                Map.put(acc, key, updated_object)
              else
                used = if is_nil(val["monthly_limit"]), do: nil, else: 0

                updated_object =
                  Map.merge(val, %{
                    "monthly_remaining_limit" => val["monthly_limit"],
                    "monthly_used_limit" => used
                  })

                Map.put(acc, key, updated_object)
              end
          end

        true ->
          acc
      end
    end)
  end

  def update_subscription_for_custom_items(plan, %{annual: annual} = params) do
    [discount_percentage, plan_price] = apply_plan_discount(plan, annual)
    plan = Map.from_struct(plan) |> exclude_plan_inactive_features()

    plan =
      Enum.reduce_while(params, plan, fn
        {feature, %{quantity: quantity}}, acc ->
          case custom_items(feature, quantity, plan, acc, annual, plan_price, discount_percentage) do
            {:error, error} -> {:halt, {:error, error}}
            acc -> {:cont, acc}
          end

        {_, _}, %{price: _} = acc ->
          {:cont, acc}

        {_, _}, acc ->
          {:cont, Map.merge(acc, %{price: plan_price})}
      end)

    case plan do
      {:error, error} -> {:error, error}
      plan -> Map.merge(%Core.Schemas.PaypalSubscriptionPlan{}, plan)
    end
  end

  def exclude_plan_inactive_features(plan) do
    Enum.reduce(plan, plan, fn {k, v}, acc ->
      case v do
        %{"active" => active, "included" => included} when not active or not included ->
          Map.delete(acc, k)

        _ ->
          acc
      end
    end)
  end

  defp apply_plan_discount(plan, annual) do
    discount_percentage =
      case plan do
        %{
          plan_discount: %{
            "begin_date" => begin_date,
            "end_date" => end_date,
            "discount_percentage" => discount
          }
        } ->
          begin_date =
            case DateTime.from_iso8601(begin_date) do
              {:ok, datetime, _} -> datetime
              _ -> begin_date
            end

          end_date =
            case DateTime.from_iso8601(end_date) do
              {:ok, datetime, _} -> datetime
              _ -> end_date
            end

          if Timex.between?(DateTime.utc_now(), begin_date, end_date, inclusive: true) do
            if is_nil(discount), do: 0, else: discount
          else
            0
          end

        _ ->
          0
      end

    price = if annual, do: plan.annual_price, else: plan.monthly_price
    discounted_price = discount_percentage * price / 100
    [discount_percentage, CommonFunctions.round_off_value(price - discounted_price)]
  end

  def custom_items(feature, quantity, plan, acc, annual, plan_price, global_discount_percentage) do
    if is_nil(plan[feature]) do
      {:error, ["#{to_string(feature)} is not active or included"]}
    else
      plan_limit =
        cond do
          is_nil(plan[feature]["annual_limit"]) and is_nil(plan[feature]["monthly_limit"]) and
              (plan[feature]["limit"] == "unlimited" or plan[feature]["limit"] == "Unlimited") ->
            "unlimited"

          is_nil(plan[feature]["annual_limit"]) and is_nil(plan[feature]["monthly_limit"]) ->
            0

          true ->
            if annual, do: plan[feature]["annual_limit"], else: plan[feature]["monthly_limit"]
        end

      [limit_data, plan_price] =
        cond do
          plan_limit == "unlimited" or plan_limit == "Unlimited" ->
            [%{"additional_added" => nil, "plan_default_annual_limit" => plan_limit}, plan_price]

          is_integer(plan_limit) ->
            additional_lots = getting_total_lots(plan[feature], quantity, plan_limit)
            unit_price = plan[feature]["unit_price"]

            additional_price =
              applying_discounts(
                plan[feature],
                unit_price,
                additional_lots,
                global_discount_percentage
              )

            plan_price =
              case acc do
                %{price: cumulative_plan_price} ->
                  CommonFunctions.round_off_value(cumulative_plan_price + additional_price)

                _ ->
                  CommonFunctions.round_off_value(plan_price + additional_price)
              end

            if annual do
              [
                %{
                  "additional_added" => quantity - plan_limit,
                  "plan_default_annual_limit" => plan_limit,
                  "annual_limit" => quantity
                },
                plan_price
              ]
            else
              [
                %{
                  "additional_added" => quantity - plan_limit,
                  "plan_default_monthly_limit" => plan_limit,
                  "monthly_limit" => quantity
                },
                plan_price
              ]
            end

          true ->
            [
              %{"additional_added" => nil, "plan_default_monthly_limit" => "unlimited"},
              plan_price
            ]
        end

      updated_features = Map.merge(plan[feature], limit_data)
      Map.put(acc, feature, updated_features) |> Map.put(:price, plan_price)
    end
  end

  def getting_total_lots(feature, quantity, plan_limit) do
    if feature["unit_of_measure"] == "lot" do
      lot_size = feature["lot_size"]

      lot_size =
        if (is_integer(lot_size) or is_float(lot_size)) and lot_size > 0,
          do: trunc(lot_size),
          else: 1

      if rem(quantity - plan_limit, lot_size) == 0 do
        trunc((quantity - plan_limit) / lot_size)
      else
        trunc((quantity - plan_limit) / lot_size) + 1
      end
    else
      quantity - plan_limit
    end
  end

  def getting_number_of_features_per_lot(feature) do
    if feature["unit_of_measure"] == "lot" do
      lot_size = feature["lot_size"]

      if (is_integer(lot_size) or is_float(lot_size)) and lot_size > 0,
        do: trunc(lot_size),
        else: 1
    else
      1
    end
  end

  def applying_discounts(feature, unit_price, additional_lots, global_discount_percentage) do
    if is_integer(unit_price) or is_float(unit_price) do
      all_lots_price = unit_price * additional_lots
      promo_discount = feature["lot_discount"]

      if is_integer(promo_discount) or is_float(promo_discount) do
        #              lot discount applied
        lot_discount_price = promo_discount * all_lots_price / 100
        lots_discounted_price = all_lots_price - lot_discount_price
        #               global discount applied after lot discount application
        lot_discount_price = global_discount_percentage * lots_discounted_price / 100
        (lots_discounted_price - lot_discount_price) |> CommonFunctions.round_off_value()
      else
        (all_lots_price - global_discount_percentage * all_lots_price / 100)
        |> CommonFunctions.round_off_value()
      end

      #          not is_integer(unit_price) or not is_float(unit_price) -> 0
    else
      0
    end
  end

  def get_user(%{user_id: user_id}) do
    case Accounts.get_user!(user_id) do
      nil -> {:error, ["this user doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def get_business(%{business_id: business_id}) do
    case BSP.get_business(business_id) do
      nil -> {:error, ["this business doesn't exist!"]}
      %{} = data -> {:ok, data}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def create_available_promotion(%{
        broad_cast_range: range,
        business_id: business_id,
        rule_id: _rule,
        price: promotion_price,
        plan: _plan,
        annual: annual,
        country_id: _country_id
      }) do
    months = if annual, do: 12, else: 1
    expire_at = Timex.shift(DateTime.utc_now(), months: months)

    params = %{
      price: promotion_price,
      broadcast_range: range,
      additional: false,
      business_id: business_id,
      begin_at: DateTime.utc_now(),
      expire_at: expire_at
    }

    case Promotions.create_available_promotion(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["available promotion isn't created"]}
    end
  end

  def get_paypal_subscription(paypal_subscription_id) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token}} ->
        url = System.get_env("PAYPAL_SUBSCRIPTION_URL") <> "/" <> paypal_subscription_id

        headers = [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        case HTTPoison.get(url, headers, hackney: [basic_auth: R.auth()]) do
          {:ok, data} ->
            case Poison.decode(data.body) do
              {:error, error, _} ->
                {:error, error}

              {:error, error} ->
                {:error, error}

              {:ok, %{"error_description" => error} = _data} ->
                {:error, error}

              {:ok, %{"message" => _, "details" => [%{"description" => error} | _]} = _data} ->
                {:error, error}

              {:ok, %{"links" => _links} = data} ->
                {:ok, data}

              _ ->
                {:error, ["No case clause matching"]}
            end

          exception ->
            logger(__MODULE__, exception, ["Unable to confirm Paypal Subscription"], __ENV__.line)
        end
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong while confirming Paypal Subscription"],
        __ENV__.line
      )
  end

  def get_subscriber(%{user_id: user_id} = params) do
    case params do
      %{subscriber: subscriber} ->
        subscriber

      _ ->
        case PaypalPayments.get_default_paypal_seller_account_by_user(user_id) do
          %{email: email} -> %{subscriber_id: email}
          _ -> nil
        end
    end
  end

  #  for any feature other than promotion purchase
  def update_subscription_features(branch_id, slug, feature_ids) do
    case PaypalPayments.get_paypal_subscription_by_branch(branch_id) do
      [] ->
        {:error, ["no subscription exists"]}

      [%{} = subscription | _] ->
        feature = Map.get(subscription, String.to_atom(slug))
        count = getting_number_of_features_per_lot(feature) * Enum.count(feature_ids)

        feature =
          case feature do
            %{"monthly_remaining_limit" => monthly_remaining} when is_nil(monthly_remaining) ->
              Map.merge(feature, %{"monthly_remaining_limit" => count})

            %{"annual_remaining_limit" => annual_remaining} when is_nil(annual_remaining) ->
              Map.merge(feature, %{"annual_remaining_limit" => count})

            %{"monthly_remaining_limit" => monthly_remaining}
            when not is_nil(monthly_remaining) ->
              Map.merge(feature, %{"monthly_remaining_limit" => monthly_remaining + count})

            %{"annual_remaining_limit" => annual_remaining} when not is_nil(annual_remaining) ->
              Map.merge(feature, %{"annual_remaining_limit" => annual_remaining + count})

            _ ->
              feature
          end

        feature =
          case feature do
            %{"monthly_used_limit" => monthly_used} when is_nil(monthly_used) ->
              Map.merge(feature, %{"monthly_used_limit" => 0})

            %{"annual_used_limit" => annual_used} when is_nil(annual_used) ->
              Map.merge(feature, %{"annual_used_limit" => 0})

            _ ->
              feature
          end

        updates_feature =
          case feature do
            %{"monthly_limit" => monthly} when is_nil(monthly) ->
              Map.merge(feature, %{"monthly_limit" => count})

            %{"annual_limit" => annual} when not is_nil(annual) ->
              Map.merge(feature, %{"annual_limit" => annual + count})

            _ ->
              feature
          end

        case PaypalPayments.update_paypal_subscription(subscription, %{slug => updates_feature}) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
        end
    end
  end

  #  for promotion purchase
  def update_subscription_features(branch_id) do
    case PaypalPayments.get_paypal_subscription_by_branch(branch_id) do
      [] ->
        {:error, ["no subscription exists"]}

      [%{} = subscription | _] ->
        feature =
          case subscription.promotions do
            %{"monthly_remaining_limit" => monthly_remaining} when is_nil(monthly_remaining) ->
              Map.merge(subscription.promotions, %{"monthly_remaining_limit" => 1})

            %{"annual_remaining_limit" => annual_remaining} when is_nil(annual_remaining) ->
              Map.merge(subscription.promotions, %{"annual_remaining_limit" => 1})

            %{"monthly_remaining_limit" => monthly_remaining}
            when not is_nil(monthly_remaining) ->
              Map.merge(subscription.promotions, %{
                "monthly_remaining_limit" => monthly_remaining + 1
              })

            %{"annual_remaining_limit" => annual_remaining} when not is_nil(annual_remaining) ->
              Map.merge(subscription.promotions, %{
                "annual_remaining_limit" => annual_remaining + 1
              })

            _ ->
              subscription.promotions
          end

        feature =
          case feature do
            %{"monthly_used_limit" => monthly_used} when is_nil(monthly_used) ->
              Map.merge(subscription.promotions, %{"monthly_used_limit" => 0})

            %{"annual_used_limit" => annual_used} when is_nil(annual_used) ->
              Map.merge(subscription.promotions, %{"annual_used_limit" => 0})

            _ ->
              subscription.promotions
          end

        updates_feature =
          case feature do
            %{"monthly_limit" => monthly} when is_nil(monthly) ->
              Map.merge(subscription.promotions, %{"monthly_limit" => 0})

            %{"annual_limit" => annual} when is_nil(annual) ->
              Map.merge(subscription.promotions, %{"annual_limit" => 0})

            _ ->
              subscription.promotions
          end

        case PaypalPayments.update_paypal_subscription(subscription, %{
               promotions: updates_feature
             }) do
          {:ok, data} -> {:ok, data}
          {:error, error} -> {:error, error}
        end
    end
  end
end
