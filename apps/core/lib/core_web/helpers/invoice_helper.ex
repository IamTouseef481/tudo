defmodule CoreWeb.Helpers.InvoiceHelper do
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{Accounts, Employees, Invoices, Jobs, Promotions, Services, Settings, Bids}
  alias Core.Jobs.JobNotificationHandler
  alias CoreWeb.Controllers.{InvoiceController, PromotionController}
  alias CoreWeb.GraphQL.Resolvers.InvoiceResolver
  alias CoreWeb.Helpers.JobHelper
  alias CoreWeb.Utils.CommonFunctions

  #
  # Main actions
  #
  def create_invoice_from(params) do
    new()
    |> run(:invoice, &create_invoice_from/2, &abort/3)
    #    |> run(:update_job_status, &update_job_status_for_generate_invoice/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def generate_invoice(params) do
    new()
    |> run(:invoice, &get_invoice_by/2, &abort/3)
    |> run(:generate_invoice, &generate_invoice/2, &abort/3)
    |> run(:update_job, &update_job_for_generate_invoice/2, &abort/3)
    #    |> run(:update_job_status, &update_job_status_for_generate_invoice/2, &abort/3)
    #    |> run(:send_notification, &send_notification_for_generate_invoice/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def adjust_invoice(params) do
    new()
    |> run(:get_invoice, &get_invoice_for_cmr/2, &abort/3)
    |> run(:valid_for_adjust, &check_validity_for_adjust/2, &abort/3)
    |> run(:adjust_invoice, &adjust_invoice/2, &abort/3)
    |> run(:update_job, &update_job_for_adjust_invoice/2, &abort/3)
    #    |> run(:update_job_status, &update_job_status_for_adjust_invoice/2, &abort/3)
    #    |> run(:send_notification, &send_notification_for_adjust_invoice/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp get_invoice_by(_, params) do
    case Invoices.get_invoice_by_job(params) do
      [] -> {:error, {"invoice doesn't exist!"}}
      [invoice] -> {:ok, invoice}
    end
  end

  def create_invoice_from(
        _,
        %{business_id: _business_id, branch_id: branch_id} = input
      ) do
    branh_service =
      if Map.get(input, :bid_proposal_id) do
        %{bs_id: input.branch_service_id, promotion_id: nil}
      else
        %{branch_service_id: bs_id, promotion_id: promotion_id, branch_service_ids: bs_ids} =
          Jobs.get_job(input.job_id)

        bs_id = bs_id || bs_ids
        %{bs_id: bs_id, promotion_id: promotion_id}
      end

    cs_id =
      case Services.get_branch_service(branh_service.bs_id) do
        %{country_service_id: cs_id, service_type_id: _type} -> [cs_id]
        data when is_list(data) -> Enum.map(data, & &1.country_service_id)
      end

    case Settings.get_settings_by(%{branch_id: branch_id, slug: "sales_tax_rate"}) do
      nil ->
        {:error, ["Business Sales Tax settings not found"]}

      %{fields: fields} ->
        #    taxes = Enum.map(Taxes.get_taxes_by(input), & Map.from_struct(&1))
        #            |> InvoiceController.clean_taxes() |> InvoiceController.rounding_taxes_value()
        taxes = fetch_taxes(fields, cs_id)
        creates_invoice_from(Map.merge(input, %{promotion_id: branh_service.promotion_id}), taxes)

      _ ->
        {:error, ["Error in fetching Sales Tax settings"]}
    end
  end

  defp fetch_taxes(fields, cs_id) do
    country_ids = Invoices.get_country_id_by(cs_id)

    if 500 in country_ids do
      []
    else
      Enum.map(fields["service_rate_card"], fn tax ->
        if tax["is_common_tax"] do
          %{
            title: tax["common_tax_title"],
            is_percentage: tax["is_percentage"],
            value: tax["common_tax_rate"],
            default: true
          }
        else
          Enum.reduce_while(tax["services"], %{}, fn service, _acc ->
            if service["country_service_id"] in cs_id do
              {:halt,
               %{
                 title: service["tax_title"],
                 is_percentage: tax["is_percentage"],
                 value: service["tax_rate"],
                 default: true
               }}
            else
              {:cont,
               %{
                 title: service["tax_title"],
                 is_percentage: tax["is_percentage"],
                 value: tax["common_tax_rate"],
                 default: true
               }}
            end
          end)
        end
      end)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to compute Estimated Cost for Job!"], __ENV__.line)
  end

  defp creates_invoice_from(
         %{branch_id: _branch_id, business_id: _bus_id, promotion_id: promotion_id} = input,
         taxes
       ) do
    promotions =
      case promotion_id do
        nil ->
          make_promotions_map_form_struct(PromotionController.get_promotions_by(input))

        promotion_id ->
          case Promotions.get_promotion(promotion_id) do
            %{is_combined: true} = promotion ->
              make_promotions_map_form_struct([promotion])

            %{is_combined: false} ->
              make_promotions_map_form_struct(PromotionController.get_promotions_by(input))

            _ ->
              []
          end
      end

    amount = [
      %{
        unit_price: input.unit_price,
        quantity: 1,
        service_id: input[:service_id] || input[:service_ids],
        service_title: input[:service_names] || input[:name],
        discount_eligibility: true,
        tax_eligibility: true
      }
    ]

    bsp_id = Employees.get_employee!(input.employee_id).user_id
    input = Map.merge(input, %{bsp_id: bsp_id})
    calculate_final_amount_and_create_invoice_or_quotes(taxes, promotions, amount, input)
  end

  def calculate_final_amount_and_create_invoice_or_quotes(taxes, promotions, amount, input) do
    case InvoiceController.calculate_final_amount(promotions, taxes, amount) do
      {:ok, amount_and_taxes} ->
        employee_name =
          Accounts.get_user!(input.bsp_id).profile[
            "first_name"
          ]

        rep = "##{input.bsp_id}, #{employee_name}"
        bill_to = "##{input.cmr_id}, #{Accounts.get_user!(input.cmr_id).profile["first_name"]}"

        payment_type =
          case input do
            %{payment_type: payment_type} -> payment_type
            _ -> "card"
          end

        create_invoice_or_quotes(
          input,
          amount_and_taxes,
          rep,
          bill_to,
          input.branch_id,
          payment_type,
          input.business_id,
          promotions,
          taxes,
          amount
        )

      {:error, error} ->
        {:error, error}
    end
  end

  def create_invoice_or_quotes(
        %{bid_proposal_id: bid_proposal_id} = input,
        amount_and_taxes,
        rep,
        bill_to,
        branch_id,
        payment_type,
        bus_id,
        promotions,
        taxes,
        amount
      ) do
    [final_amount, total_charges, total_discount, total_tax] = amount_and_taxes

    params = %{
      bid_proposal_id: bid_proposal_id,
      discounts: promotions,
      taxes: taxes,
      amounts: amount,
      adjust: true,
      final_amount: final_amount,
      total_tax: total_tax,
      total_discount: total_discount,
      total_charges: total_charges,
      rep: rep,
      bill_to: bill_to,
      branch_id: branch_id,
      business_id: bus_id,
      payment_type: payment_type
    }

    case Bids.create_bid_proposal_quotes(params) do
      {:ok, bid_quote} ->
        add_data(
          Map.merge(params, %{country_id: input.country_id}),
          bid_quote,
          promotions,
          amount,
          taxes
        )

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["Failed to generate Invoice, try again!"]}
    end
  end

  def create_invoice_or_quotes(
        input,
        amount_and_taxes,
        rep,
        bill_to,
        branch_id,
        payment_type,
        bus_id,
        promotions,
        taxes,
        amount
      ) do
    [final_amount, total_charges, total_discount, total_tax] = amount_and_taxes

    params = %{
      job_id: input[:job_id],
      order_id: input[:order_id],
      discounts: promotions,
      taxes: taxes,
      amounts: amount,
      adjust: true,
      final_amount: final_amount,
      total_tax: total_tax,
      total_discount: total_discount,
      total_charges: total_charges,
      rep: rep,
      bill_to: bill_to,
      branch_id: branch_id,
      business_id: bus_id,
      payment_type: payment_type,
      reference_no: input[:job_id],
      is_quote: input.is_quote,
      country_id: input[:country_id]
    }

    case Invoices.create_invoice(params) do
      {:ok, invoice} ->
        add_data(params, invoice, promotions, amount, taxes)

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["Failed to generate Invoice, try again!"]}
    end
  end

  def add_data(params, invoice, promotions, amount, taxes) do
    case InvoiceController.get_settings(params) do
      {:ok, %{max_allowed_tax: max_allowed_tax, max_allowed_discount: max_allowed_discount}} ->
        discounts = InvoiceController.add_discount_value(promotions, amount)
        taxes = InvoiceController.add_tax_value(taxes, amount)

        invoice =
          Map.merge(invoice, %{
            max_allowed_discount: max_allowed_discount,
            invoice_date: invoice.inserted_at,
            max_allowed_tax: max_allowed_tax,
            taxes: taxes,
            discounts: discounts,
            amounts: amount,
            country_id: params[:country_id]
          })
          |> InvoiceResolver.add_insurance_and_booking_percentage()

        {:ok, invoice}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["setting fields doesn't have valid keys"]}
    end
  end

  defp make_promotions_map_form_struct(promotions_list) do
    Enum.map(
      promotions_list,
      &(Map.from_struct(&1)
        |> Map.drop([:__meta__, :promotion_status, :discount_type, :promotion_pricing, :branch]))
    )
    |> InvoiceController.rounding_promotions_value()
  end

  #  defp get_invoice_for_cmr(_, %{id: id} = params) do
  #    a = case Invoices.get_invoice(id) do
  #      nil -> {:error, {"invoice doesn't exist!"}}
  #      %{job_id: job_id} = invoice ->
  #        case Jobs.get_job(job_id) do
  #          nil -> {:error, {"job doesn't exist!"}}
  #          %{inserted_by: cmr_id} = job ->
  #            if cmr_id == params.user_id, do: {:ok, invoice}, else: {:error, ["you are not permitted to adjust this invoice"]}
  #        end
  #    end
  #  rescue
  #    _ -> {:error, ["Invalid Job or Invoice, try again!"]}
  #  end
  defp get_invoice_for_cmr(_, %{id: id} = params) do
    with %{job_id: job_id} = invoice <- Invoices.get_invoice(id),
         %{inserted_by: cmr_id} <- Jobs.get_job(job_id) do
      if cmr_id == params.user_id,
        do: {:ok, invoice},
        else: {:error, ["you are not permitted to adjust this invoice"]}
    else
      {:error, error} -> {:error, error}
    end
  rescue
    _ -> {:error, ["Invalid Job or Invoice, try again!"]}
  end

  defp generate_invoice(%{invoice: invoice}, params) do
    params =
      case params do
        %{taxes: taxes} ->
          if taxes == [],
            do: Map.merge(params, %{no_tax_concent: true}),
            else: Map.merge(params, %{no_tax_concent: false})

        _ ->
          params
      end

    case Invoices.update_invoice(invoice, params) do
      {:ok, invoice} ->
        case InvoiceController.get_settings(params) do
          {:ok, %{max_allowed_tax: max_allowed_tax, max_allowed_discount: max_allowed_discount}} ->
            discounts = InvoiceController.add_discount_value(invoice.discounts, invoice.amounts)
            taxes = InvoiceController.add_tax_value(invoice.taxes, invoice.amounts)

            invoice =
              Map.merge(invoice, %{
                max_allowed_discount: max_allowed_discount,
                max_allowed_tax: max_allowed_tax,
                taxes: taxes,
                discounts: discounts,
                invoice_date: invoice.inserted_at
              })

            {:ok, invoice}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["setting fields doesn't have valid keys"]}
        end

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  defp check_validity_for_adjust(%{get_invoice: invoice}, _params) do
    with %{employee_id: employee_id} <- Jobs.get_job(invoice.job_id),
         %{branch_id: branch_id} <- Employees.get_employee(employee_id) do
      %{fields: %{"max_invoice_adjust_count" => %{"max_value" => max_adjust_count}}} =
        Settings.get_settings_by(%{slug: "max_invoice_adjust_count", branch_id: branch_id})

      if invoice.adjust_count < max_adjust_count do
        {:ok, ["valid for adjust"]}
      else
        {:error, ["Max allowed Invoice adjustments/day limit reached!"]}
      end
    else
      _ -> {:error, ["Unable to check Invoice adjustments/day count"]}
    end
  end

  defp adjust_invoice(%{get_invoice: %{adjust_count: count} = invoice}, params) do
    params = Map.merge(params, %{adjust_count: count + 1})

    case Invoices.update_invoice(invoice, params) do
      {:ok, invoice} ->
        amounts = CommonFunctions.keys_to_atoms(invoice.amounts)
        invoice = Map.merge(invoice, %{amounts: amounts})
        {:ok, invoice}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["Unexpected error occurred, try again!"]}
    end
  end

  defp update_job_for_generate_invoice(
         %{generate_invoice: %{is_quote: true}},
         params
       ),
       do: {:ok, params}

  defp update_job_for_generate_invoice(
         %{invoice: %{job_id: job_id} = invoice, generate_invoice: %{final_amount: final_amount}},
         %{user_id: user_id} = _params
       ) do
    job = Jobs.get_job(job_id)

    params =
      if final_amount <= 0 do
        case job do
          %{job_cmr_status_id: "completed"} = _job ->
            %{
              id: job_id,
              job_status_id: "paid",
              job_bsp_status_id: "paid",
              job_cmr_status_id: "paid",
              is_invoice_amount_non_positive: true
            }
        end
      else
        case job do
          %{job_cmr_status_id: "adjust_invoice"} = _job ->
            %{
              id: job_id,
              job_bsp_status_id: "adjusted",
              job_cmr_status_id: "adjusted",
              job_status_id: "invoiced"
            }

          %{job_bsp_status_id: "adjust_invoice"} = _job ->
            %{
              id: job_id,
              job_bsp_status_id: "adjusted",
              job_cmr_status_id: "adjusted",
              job_status_id: "invoiced"
            }

          _ ->
            %{
              id: job_id,
              job_status_id: "invoiced",
              job_bsp_status_id: "invoiced",
              job_cmr_status_id: "invoiced"
            }
        end
      end

    with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
           JobHelper.update_job(Map.merge(params, %{updated_by: user_id})),
         _ <- JobNotificationHandler.send_notification_for_update_job(previous_job, job, params),
         _ <- Invoices.update_invoice(invoice, %{is_quote: false}) do
      {:ok, job}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp update_job_for_adjust_invoice(%{get_invoice: %{is_quote: true}}, _),
    do: {:ok, ["No need to update job status when quote is true"]}

  defp update_job_for_adjust_invoice(
         %{get_invoice: %{job_id: job_id}},
         %{user_id: user_id} = params
       ) do
    params =
      case Jobs.get_job(job_id) do
        nil ->
          {:error, ["job doesn't exist!"]}

        %{} = _job ->
          %{
            id: job_id,
            adjust_reason: params[:adjust_reason],
            job_status_id: "invoiced",
            job_bsp_status_id: "adjust_invoice",
            job_cmr_status_id: "adjust_invoice"
          }
      end

    with {:ok, _, %{job: job, is_job_exist: previous_job, rescheduling_statuses: params}} <-
           JobHelper.update_job(Map.merge(params, %{updated_by: user_id})),
         _ <- JobNotificationHandler.send_notification_for_update_job(previous_job, job, params) do
      {:ok, job}
    else
      {:error, error} -> {:error, error}
    end
  end

  #  def send_notification_for_adjust_invoice(%{get_invoice: %{job_id: job_id}}, _params) do
  #    %{employee_id: employee_id, inserted_by: cmr_id, service_type_id: service_type} = prev_job = Jobs.get_job(job_id)
  #    JobNotificationHandler.send_notification_for_update_job(prev_job, %{employee_id: employee_id, id: job_id,
  #      inserted_by: cmr_id, service_type_id: service_type}, %{job_bsp_status_id: "adjust_invoice"})
  #  rescue
  #    _ -> {:ok, [""]}
  #  end

  #  def send_notification_for_generate_invoice(%{invoice: %{job_id: job_id}}, _params) do
  #    case Jobs.get_job(job_id) do
  #      nil -> {:error, ["job doesn't exist!"]}
  #      %{employee_id: employee_id, inserted_by: cmr_id, service_type_id: service_type,
  #        job_cmr_status_id: "adjust_invoice"} = previous_job ->
  #        JobNotificationHandler.send_notification_for_update_job(previous_job, %{employee_id: employee_id, id: job_id,
  #          inserted_by: cmr_id, service_type_id: service_type}, %{job_cmr_status_id: "adjusted"})
  #      %{employee_id: employee_id, inserted_by: cmr_id, service_type_id: service_type} = previous_job ->
  #        JobNotificationHandler.send_notification_for_update_job(previous_job, %{employee_id: employee_id, id: job_id,
  #          inserted_by: cmr_id, service_type_id: service_type}, %{job_cmr_status_id: "invoiced"})
  #    end
  #  rescue
  #    _ -> {:ok, [""]}
  #  end
  #
  #  defp invoice_history_params(%{invoice: %{id: invoice_id}},  %{job_id: job_id} = params) do
  #    case Jobs.get_job(job_id) do
  #      nil -> {:error, ["job doesn't exist!"]}
  #      %{cost: unit_price, branch_service_id: branch_service_id} ->   #cost, fee, unit_fee
  #        case Services.get_service_by_branch_service(branch_service_id) do
  #          %{id: service_id, name: service_name} ->
  #            param = %{invoice_id: invoice_id, amount: %{unit_price: unit_price, quantity: 1, service_id: service_id, service_name: service_name}}
  #            params = Map.merge(params, param)
  #            {:ok, params}
  #          _ -> {:error, ["error in getting service!"]}
  #        end
  #      _ -> {:error, ["error in getting job and service data"]}
  #    end
  #  end
  #
  #  defp create_invoice_history(%{invoice_history_params: params}, _params) do
  #    case Invoices.create_invoice_history(params) do
  #      {:ok, invoice_history} -> {:ok, invoice_history}
  #      {:error, error} -> {:error, error}
  #      _ -> {:error, ["unexpected error occurred"]}
  #    end
  #  end
  #
  #  defp create_invoice_history(_, _) do
  #    {:ok, :not_applicable}
  #  end

  #  defp update_invoice_history(_, params) do
  #    case Invoices.create_invoice_history(params) do
  #      {:ok, invoice} -> {:ok, invoice}
  #      {:error, error} -> {:error, error}
  #      _ -> {:error, ["unexpected error occurred"]}
  #    end
  #  end
  #
  #  defp update_invoice_history(_, _) do
  #  {:ok, :not_applicable}
  #  end
end
