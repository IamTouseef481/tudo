defmodule CoreWeb.Helpers.PaypalOrderHelper do
  #   Core.PaypalPayments.Sages.Order
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{BSP, Jobs, Payments, Promotions, Orders}
  alias Core.Jobs.JobNotificationHandler
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias Core.PaypalPayments.SubscriptionHandler
  alias CoreWeb.Controllers.PaypalPaymentController
  alias CoreWeb.GraphQL.Resolvers.PaypalPaymentResolver, as: PPPaymentResolver
  alias CoreWeb.Helpers.{BtTransactionHelper, JobHelper, JobStatusesHelper}
  alias CoreWeb.Utils.HttpRequest
  alias CoreWeb.GraphQL.Resolvers.OrderResolver

  @common_error ["Something went wrong, can't create local transaction"]

  def create_paypal_order(params) do
    new()
    #    |> run(:customer_validation, &customer_validation/2, &abort/3)
    |> run(:verify_branch, &verify_branch_on_subscription_purchase/2, &abort/3)
    |> run(:verify_item_amount, &verify_transaction_amount_with_purpose/2, &abort/3)
    |> run(:altered_params, &calculate_tips_and_donations/2, &abort/3)
    |> run(:verfy_payable_amount, &verify_total_payable_amount/2, &abort/3)
    |> run(:local_transaction, &create_local_transaction/2, &abort/3)
    |> run(:paypal_order, &create_paypal_order/2, &abort/3)
    |> run(:updated_local_transaction, &update_local_transaction/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def capture_paypal_order(params) do
    new()
    |> run(:customer_validation, &customer_validation/2, &abort/3)
    |> run(:local_transaction, &get_local_transaction/2, &abort/3)
    |> run(:subsription, &update_subscription_for_features/2, &abort/3)
    |> run(:update_purpose, &update_purpose_for_paid/2, &abort/3)
    |> run(:make_cmr_payment_active, &make_local_payment_active_for_cmr/2, &abort/3)
    |> run(:payment_available_for_bsp, &make_payment_available_for_bsp/2, &abort/3)
    |> run(:update_balance, &update_balance/2, &abort/3)
    |> run(:update_cmr_spent_amount, &update_cmr_spent_amount/2, &abort/3)
    |> run(:paypal_order, &capture_paypal_order/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def get_paypal_order(transaction_id) do
    new()
    |> run(:paypal_order, &get_paypal_order/2, &abort/3)
    |> transaction(Core.Repo, transaction_id)
  end

  def void_authorize_payment(auth_id) do
    new()
    |> run(:payment, &void_authorize_payment/2, &abort/3)
    |> transaction(Core.Repo, auth_id)
  end

  # -------------------------create_paypal_order----------------------
  def customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid user password"]}
    end
  end

  def customer_validation(_, %{user: user}), do: {:ok, user}

  def verify_branch_on_subscription_purchase(_, %{branch_id: branch_id}) do
    case BSP.get_branch!(branch_id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{status_id: "confirmed"} = branch -> {:ok, branch}
      %{status_id: _} -> {:error, ["branch is not approved"]}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  def verify_branch_on_subscription_purchase(_, _), do: {:ok, ["valid"]}

  def verify_transaction_amount_with_purpose(_, %{cash_payment_id: _cash_payment_id} = params) do
    case AMC.verify_transaction_amount_with_purpose(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def verify_transaction_amount_with_purpose(_, params) do
    case AMC.verify_transaction_amount_with_purpose(
           Map.merge(params, %{payment_gateway: "paypal"})
         ) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  #  BSP side transaction flow
  def calculate_tips_and_donations(_, %{cash_payment_id: _} = params), do: {:ok, params}
  def calculate_tips_and_donations(_, %{promotion_pricing_id: _} = params), do: {:ok, params}

  def calculate_tips_and_donations(_, %{subscription_feature_slug: _} = params),
    do: {:ok, params}

  def calculate_tips_and_donations(_, %{custom_fields: _custom_fields, amount: _amount} = params) do
    case AMC.calculate_tips_and_donations(params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Error in adding Donations and Gratuity!"]}
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't add Donations and Gratuity!"],
        __ENV__.line
      )
  end

  def calculate_tips_and_donations(_, params) do
    Map.merge(params, %{
      custom_fields: %{invoice_amount: params.amount, bsp_amount: params.amount}
    })
    |> AMC.add_other_tudo_charges(params.amount)
  end

  def verify_total_payable_amount(%{altered_params: %{amount: calculated_amount}}, %{
        payable_amount: payable_amount
      }) do
    case AMC.verify_total_payable_amount(calculated_amount, payable_amount) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def verify_total_payable_amount(_, _), do: {:ok, ["valid"]}

  #  BSP transaction to Tudo
  def create_local_transaction(
        _,
        %{
          user_id: user_id,
          country_id: _country_id,
          amount: tudo_amount,
          cash_payment_id: cash_payment_id
        } = input_params
      ) do
    branch_id =
      case Core.BSP.get_branch_by_cash_payment_id(cash_payment_id) do
        %{id: branch_id} -> branch_id
        _ -> nil
      end

    #    paypal_fee = AMC.get_tudo_charges("paypal_fee", params.amount, country_id)  |> round_off_value()
    #    tudo_amount = round_off_value(params.amount - paypal_fee)
    params = %{
      user_id: user_id,
      total_transaction_amount: tudo_amount,
      tudo_total_amount: tudo_amount,
      from_bsp: true,
      branch_id: branch_id,
      bsp_payment_status_id: "pending",
      payment_purpose: %{cash_payment_id: cash_payment_id},
      payment_method_id: "paypal",
      paid_at: DateTime.utc_now(),
      paypal_fee: 0
    }

    params =
      if Map.has_key?(input_params, :payment_method_id) do
        Map.merge(params, %{payment_method_id: input_params.payment_method_id})
      else
        params
      end

    case Payments.create_payment(params) do
      {:ok, local_payment} -> {:ok, local_payment}
      {:error, _error} -> {:error, ["Something went wrong, unable to create transaction"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def create_local_transaction(
        %{altered_params: params},
        %{user_id: user_id, country_id: _country_id, promotion_pricing_id: promotion_pricing_id} =
          _input_params
      ) do
    branch_id =
      case Payments.get_promotion_purchase_price(promotion_pricing_id) do
        %{branch_id: branch_id} -> branch_id
        _ -> nil
      end

    #    paypal_fee = AMC.get_tudo_charges("paypal_fee", params.amount, country_id)  |> round_off_value()
    #    tudo_amount = round_off_value(params.amount - paypal_fee)
    params =
      Map.merge(
        params,
        %{
          user_id: user_id,
          total_transaction_amount: params.amount,
          tudo_total_amount: params.amount,
          from_bsp: true,
          branch_id: branch_id,
          bsp_payment_status_id: "pending",
          payment_purpose: %{promotion_pricing_id: promotion_pricing_id},
          paid_at: DateTime.utc_now(),
          paypal_fee: 0
        }
      )

    case Payments.create_payment(params) do
      {:ok, local_payment} -> {:ok, local_payment}
      {:error, _error} -> {:error, ["Something went wrong, unable to create transaction"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def create_local_transaction(
        %{verify_item_amount: subscription_features},
        %{subscription_feature_slug: _} = params
      ) do
    #    paypal_fee = AMC.get_tudo_charges("paypal_fee", params.amount, country_id)  |> round_off_value()
    #    tudo_amount = round_off_value(params.amount - paypal_fee)
    params =
      Map.merge(
        params,
        %{
          total_transaction_amount: params.amount,
          tudo_total_amount: params.amount,
          from_bsp: true,
          bsp_payment_status_id: "pending",
          payment_purpose: %{subscription_feature_ids: Enum.map(subscription_features, & &1.id)},
          paid_at: DateTime.utc_now(),
          paypal_fee: 0
        }
      )

    case Payments.create_payment(params) do
      {:ok, local_payment} -> {:ok, local_payment}
      {:error, _error} -> {:error, ["Something went wrong, unable to create transaction"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  #  CMR transaction to BSP having job id in params
  def create_local_transaction(
        %{altered_params: params},
        %{country_id: country_id} = input_params
      ) do
    currency_symbol =
      case Core.Regions.get_countries(country_id) do
        %{currency_symbol: currency_symbol} -> currency_symbol
        _ -> "$"
      end

    input_params = Map.merge(input_params, %{currency_symbol: currency_symbol})

    case AMC.creates_local_transaction(nil, "", input_params, params, "paypal") do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  def get_paypal_order(_, transaction_id) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token}} ->
        url = System.get_env("PAYPAL_ORDER_URL") <> "/#{transaction_id}"

        headers = [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        case HttpRequest.get(url, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  def void_authorize_payment(_, auth_id) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token}} ->
        url = System.get_env("PAYPAL_PAYMENT_URL") <> "/#{auth_id}/void"

        headers = [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token}
        ]

        case HttpRequest.post(url, %{}, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
          # Sending OK response because void API has no response that's why we are getting error but API is working fine.
          {:error, :invalid, _} -> {:ok, [:valid]}
        end
    end
  end

  defp create_paypal_order(transaction, params, intent) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        url = System.get_env("PAYPAL_ORDER_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        description =
          if Map.has_key?(params, :job_id) do
            case Jobs.get_job(params.job_id) do
              %{description: des} when not is_nil(des) and des != "" -> des
              %{title: title} -> title
              _ -> ""
            end
          else
            case Orders.get_order(params.order_id) do
              %{description: des} -> des
              _ -> ""
            end
          end

        currency_code =
          case Core.Regions.get_countries(params.country_id) do
            #      %{currency_code: currency_code} -> currency_code    #some currencies are not acceptable like PKR, INR
            _ -> "USD"
          end

        payer = if Map.has_key?(params, :payer), do: params.payer, else: nil

        _total_tudo_fee =
          Enum.reduce(Map.from_struct(transaction), 0, fn {k, v}, acc ->
            if k in [:tudo_total_amount, :donation_amount, :insurance_amount] and v != 0 do
              v + acc
            else
              acc
            end
          end)
          |> round_off_value()

        #          single purchase unit for BSP delayed disbursement TUDO fees deducted from total transaction amount
        #          giving issue -> disbursement mode is same for both bsp and tudo
        input =
          if intent == "CAPTURE" do
            %{
              payer: payer,
              intent: intent,
              application_context: %{
                return_url: "https://tudo.app/pages/payments-success",
                cancel_url: "https://tudo.app/pages/payments-error"
              },
              purchase_units: [
                %{
                  amount: %{
                    value: transaction.total_transaction_amount,
                    currency_code: currency_code
                  },
                  #  payee: %{email_address: PaypalPayments.get_paypal_seller_by_job_id(job_id)},
                  payment_instruction: %{
                    description: description,
                    #                  disbursement_mode: "DELAYED", #as funds needed to released after some time to BSP on a job completion
                    disbursement_mode: "INSTANT"
                    #                  platform_fees: [%{amount: %{value: total_tudo_fee, currency_code: currency_code}}]
                  }
                }
              ]
            }
          else
            %{
              payer: payer,
              intent: intent,
              application_context: %{
                return_url: "https://tudo.app/pages/payments-success",
                cancel_url: "https://tudo.app/pages/payments-error"
              },
              purchase_units: [
                %{
                  amount: %{
                    value: transaction.total_transaction_amount,
                    currency_code: currency_code
                  }
                }
              ]
            }
          end

        #          two purchase units one for BSP delayed disbursement and second one is for TUDO fees which is instant
        #          giving issue -> payee paypal email is not consented for getting payment
        #        input =
        #          %{
        #            payer: payer,
        #            intent: "CAPTURE",
        #            purchase_units: [
        #              %{
        #                reference_id: "bsp_earning",
        #                amount: %{value: transaction.bsp_total_amount, currency_code: currency_code},
        ##                payee: %{email_address: PaypalPayments.get_paypal_seller_by_job_id(job_id)},
        #                payment_instruction: %{
        ##                  disbursement_mode: "DELAYED", #as funds needed to released after some time to BSP on a job completion
        #                  disbursement_mode: "INSTANT", #
        ##                  platform_fees: [%{amount: %{value: total_tudo_fee, currency_code: currency_code}}]
        #                }
        #              },
        ##              two purchase units, one for bSP delayed disbursement, one for tudo instant disbursement, needed to check
        #              %{
        #                reference_id: "tudo_earning",
        #                amount: %{value: total_tudo_fee, currency_code: currency_code},
        #                payment_instruction: %{
        #                  disbursement_mode: "INSTANT"
        #                }
        #              }
        #            ]
        #          }
        #    input = Map.drop(input, [:amount, :currency_code, :access_token])
        #            |> Map.merge(input)
        case HttpRequest.post(url, input, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp create_paypal_order(
         %{
           local_transaction: transaction,
           altered_params: %{amount: _amount, custom_fields: _tudo_fees}
         },
         %{country_id: _, amount: _, order_id: _} = params
       ),
       do: create_paypal_order(transaction, params, "AUTHORIZE")

  defp create_paypal_order(
         %{
           local_transaction: transaction,
           altered_params: %{amount: _amount, custom_fields: _tudo_fees}
         },
         %{country_id: _country_id, amount: _invoice_amount} = params
       ),
       do: create_paypal_order(transaction, params, "CAPTURE")

  defp create_paypal_order(
         %{local_transaction: %{from_bsp: true, total_transaction_amount: tudo_amount}},
         %{country_id: country_id, cash_payment_id: _} = params
       ),
       do: creating_paypal_order(tudo_amount, country_id, params, "TUDO Dues Paid")

  defp create_paypal_order(
         %{local_transaction: %{from_bsp: true, total_transaction_amount: amount}},
         %{country_id: country_id, promotion_pricing_id: _} = params
       ),
       do: creating_paypal_order(amount, country_id, params, "Promotion purchase")

  defp create_paypal_order(
         %{local_transaction: %{from_bsp: true, total_transaction_amount: amount}},
         %{country_id: country_id, subscription_feature_slug: slug} = params
       ),
       do: creating_paypal_order(amount, country_id, params, slug <> " purchase")

  defp creating_paypal_order(amount, country_id, params, description) do
    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        #        paypal_partner_attribution_id = "FLAVORsb-cxm47s5549184_MP"
        url = System.get_env("PAYPAL_ORDER_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        currency_code =
          case Core.Regions.get_countries(country_id) do
            #      %{currency_code: currency_code} -> currency_code    #some currencies are not acceptable like PKR, INR
            _ -> "USD"
          end

        payer = if Map.has_key?(params, :payer), do: params.payer, else: nil

        input = %{
          payer: payer,
          intent: "CAPTURE",
          application_context: %{
            return_url: "https://tudo.app/pages/payments-success",
            cancel_url: "https://tudo.app/pages/payments-error"
          },
          purchase_units: [
            %{
              amount: %{value: amount, currency_code: currency_code},
              payment_instruction: %{
                description: description,
                # as funds needed to released immediately to tudo account on any purchase
                disbursement_mode: "INSTANT"
                #                  platform_fees: [tudo_fees]
              }
            }
          ]
        }

        #    input = Map.drop(input, [:amount, :currency_code, :access_token])
        #            |> Map.merge(input)
        case HttpRequest.post(url, input, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp update_local_transaction(
         %{paypal_order: %{id: transaction_id}, local_transaction: local_transaction},
         params
       ) do
    payment_purpose = Map.merge(local_transaction.payment_purpose, %{order_id: params[:order_id]})

    case Payments.update_payment(local_transaction, %{
           transaction_id: transaction_id,
           payment_purpose: payment_purpose
         }) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp capture_paypal_order(_, %{auth_id: auth_id}) do
    url = System.get_env("PAYPAL_PAYMENT_URL") <> "/#{auth_id}/capture"

    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        case HttpRequest.post(url, %{}, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  # -------------------------capture_paypal_order----------------------
  defp capture_paypal_order(_, %{paypal_order_id: paypal_order_id}) do
    url = System.get_env("PAYPAL_ORDER_URL") <> "/#{paypal_order_id}/capture"

    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        case HttpRequest.post(url, %{}, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} -> {:ok, keys_to_atoms(data)}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp get_local_transaction(_, %{paypal_order_id: paypal_order_id}) do
    case Payments.get_payment_by_transaction_id(paypal_order_id) do
      %{} = payment -> {:ok, payment}
      _ -> {:error, ["Local Payment against this PayPal Transaction id does not exist"]}
    end
  end

  defp update_subscription_for_features(
         %{
           local_transaction: %{
             payment_purpose: %{"subscription_feature_ids" => feature_ids},
             branch_id: branch_id
           }
         },
         %{subscription_feature_slug: _}
       ) do
    case Payments.get_available_subscription_feature(List.first(feature_ids)) do
      %{subscription_feature_slug: slug} ->
        SubscriptionHandler.update_subscription_features(branch_id, slug, feature_ids)

      _ ->
        {:error, ["no subscription feature requested to purchase"]}
    end
  end

  defp update_subscription_for_features(
         %{
           local_transaction: %{
             payment_purpose: %{"promotion_pricing_id" => _},
             branch_id: branch_id
           }
         },
         _
       ),
       do: SubscriptionHandler.update_subscription_features(branch_id)

  defp update_subscription_for_features(_, _), do: {:ok, ["valid"]}

  def update_purpose_for_paid(%{local_transaction: %{insurance_amount: insurance_amount}}, %{
        job_id: job_id,
        user_id: user_id
      }) do
    params = %{
      id: job_id,
      job_status_id: "paid",
      job_cmr_status_id: "paid",
      job_bsp_status_id: "paid",
      updated_by: user_id
    }

    insured = if insurance_amount > 0, do: true, else: false

    with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
           JobHelper.update_job(params),
         _ <- JobNotificationHandler.send_notification_for_update_job(previous_job, job, params),
         _ <-
           JobStatusesHelper.auto_finalize_job_after_payment(%{
             job_id: job_id,
             get_insured: insured
           }) do
      {:ok, job}
    else
      {:error, error} -> {:error, error}
    end
  end

  def update_purpose_for_paid(_, %{product_order_id: product_order_id, user_id: _}),
    do: OrderResolver.update_order_status(product_order_id, %{status_id: "completed"})

  def update_purpose_for_paid(
        %{local_transaction: %{payment_purpose: %{"subscription_feature_ids" => feature_ids}}},
        %{subscription_feature_slug: _}
      ) do
    features =
      Enum.reduce(feature_ids, [], fn id, acc ->
        case Payments.get_available_subscription_feature(id) do
          nil ->
            acc

          %{} = feature ->
            case Payments.update_available_subscription_feature(feature, %{active: true}) do
              {:ok, feature} -> [feature] ++ acc
              _ -> acc
            end
        end
      end)

    {:ok, features}
  end

  def update_purpose_for_paid(
        %{
          local_transaction: %{
            payment_purpose: %{"promotion_pricing_id" => promotion_pricing_id},
            branch_id: _
          }
        },
        %{promotion_pricing_id: _}
      ) do
    case Promotions.get_available_promotions_by_pricing(promotion_pricing_id) do
      nil ->
        {:ok, ["valid"]}

      %{} = promotion ->
        case Promotions.update_available_promotion(promotion, %{active: true}) do
          {:ok, feature} -> {:ok, feature}
          {:error, error} -> {:error, error}
        end
    end
  end

  def update_purpose_for_paid(_, _), do: {:ok, ["no need to update purpose"]}

  defp make_local_payment_active_for_cmr(%{local_transaction: local_transaction}, params) do
    cmr_payment_status_id =
      case params do
        %{cash_payment_id: _} -> nil
        %{promotion_pricing_id: _} -> nil
        %{subscription_feature_slug: _} -> nil
        _ -> "active"
      end

    case Payments.update_payment(
           local_transaction,
           %{cmr_payment_status_id: cmr_payment_status_id, paid_at: DateTime.utc_now()}
         ) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         promotion_pricing_id: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         cash_payment_id: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(%{local_transaction: local_transaction}, %{
         subscription_feature_slug: _
       }) do
    case Payments.update_payment(local_transaction, %{bsp_payment_status_id: "active"}) do
      {:ok, transaction} -> {:ok, transaction}
      {:error, error} -> {:error, error}
    end
  end

  defp make_payment_available_for_bsp(
         %{local_transaction: _},
         %{
           country_id: _,
           product_order_id: _
         }
       ),
       do: {:ok, []}

  defp make_payment_available_for_bsp(
         %{local_transaction: local_transaction},
         %{
           country_id: country_id
         } = params
       ) do
    branch_id =
      case Core.BSP.get_branch_id_by_job_id(params[:job_id]) do
        %{id: id} -> id
        _ -> nil
      end

    {:ok, AMC.make_payment_available_for_bsp(local_transaction.id, country_id, branch_id)}
  end

  #  BSP side transaction flow to purchase something
  defp update_balance(
         %{
           local_transaction: %{
             tudo_total_amount: tudo_amount,
             branch_id: branch_id,
             total_transaction_amount: bsp_spent_amount
           }
         },
         %{promotion_pricing_id: _promotion_pricing_id}
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          tudo_balance: tudo_amount,
          branch_id: branch_id,
          bsp_spent_amount: bsp_spent_amount
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while creating balance"]}
        end

      %{tudo_balance: tudo_balance, bsp_spent_amount: current_bsp_spent_amount} = balance ->
        tudo_balance = round_off_value(tudo_balance + tudo_amount)

        bsp_spent_amount = round_off_value(current_bsp_spent_amount + bsp_spent_amount)

        case Payments.update_balance(balance, %{
               tudo_balance: tudo_balance,
               bsp_spent_amount: bsp_spent_amount
             }) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end

  defp update_balance(
         %{
           local_transaction: %{
             tudo_total_amount: tudo_amount,
             branch_id: branch_id,
             total_transaction_amount: bsp_spent_amount
           }
         },
         %{subscription_feature_slug: _}
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      nil ->
        attrs = %{
          tudo_balance: tudo_amount,
          branch_id: branch_id,
          bsp_spent_amount: bsp_spent_amount
        }

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while creating balance"]}
        end

      %{tudo_balance: tudo_balance, bsp_spent_amount: current_bsp_spent_amount} = balance ->
        tudo_balance = round_off_value(tudo_balance + tudo_amount)

        bsp_spent_amount = round_off_value(current_bsp_spent_amount + bsp_spent_amount)

        case Payments.update_balance(balance, %{
               tudo_balance: tudo_balance,
               bsp_spent_amount: bsp_spent_amount
             }) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end
  end

  defp update_balance(
         %{
           local_transaction: %{
             tudo_total_amount: _tudo_amount,
             branch_id: branch_id,
             total_transaction_amount: bsp_paid_amount
           }
         },
         %{cash_payment_id: _cash_payment_id}
       ) do
    case Payments.get_balance_by_branch(branch_id) do
      %{tudo_due_amount: tudo_due_amount} = balance ->
        tudo_due_amount = round_off_value(tudo_due_amount - bsp_paid_amount)

        case Payments.update_balance(balance, %{tudo_due_amount: tudo_due_amount}) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:ok, ["Balance does not exist"]}
    end
  end

  # CMR side transaction flow
  defp update_balance(%{local_transaction: local_transaction}, _params) do
    case BtTransactionHelper.update_balance_on_cmr_payment_with_check_of_chargebacks(
           local_transaction
         ) do
      {:ok, balance} -> {:ok, balance}
      {:error, error} -> {:error, error}
    end
  end

  defp update_cmr_spent_amount(_, %{cash_payment_id: _}), do: {:ok, ["no CMR expense"]}
  defp update_cmr_spent_amount(_, %{promotion_pricing_id: _}), do: {:ok, ["no CMR expense"]}
  defp update_cmr_spent_amount(_, %{subscription_feature_slug: _}), do: {:ok, ["no CMR expense"]}

  defp update_cmr_spent_amount(%{local_transaction: %{total_transaction_amount: amount}}, %{
         user_id: user_id
       }) do
    case Payments.get_balance_by_cmr(user_id) do
      nil ->
        attrs = %{cmr_spent_amount: amount, user_id: user_id}

        case Payments.create_balance(attrs) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while creating Consumer spent amount"]}
        end

      %{cmr_spent_amount: cmr_spent_amount} = balance ->
        cmr_spent_amount = round_off_value(cmr_spent_amount + amount)

        case Payments.update_balance(balance, %{cmr_spent_amount: cmr_spent_amount}) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["Error while updating Consumer spent amount"]}
        end

      _ ->
        {:error, ["Error while getting Consumer spent amount"]}
    end
  end

  # ---------------------------------------------------------------------
  #  written for getting payments to check paypal_fee, not used in this module
  def get_paypal_payment(paypal_payment_id) do
    url = System.get_env("PAYPAL_GET_PAYMENT") <> paypal_payment_id

    case PaypalPaymentController.get_access_token_for_paypal_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, %{access_token: access_token, partner_attribution_id: paypal_partner_attribution_id}} ->
        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> access_token},
          {"PayPal-Partner-Attribution-Id", paypal_partner_attribution_id}
        ]

        case HttpRequest.get(url, headers, hackney: [basic_auth: PPPaymentResolver.auth()]) do
          {:ok, data} ->
            {:ok, keys_to_atoms(data)}

          {:error, error} ->
            {:error, error}
        end
    end
  end
end
