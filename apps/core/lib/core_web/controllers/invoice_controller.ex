defmodule CoreWeb.Controllers.InvoiceController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{Invoices, Settings, Taxes}
  alias CoreWeb.Controllers.PromotionController
  alias CoreWeb.GraphQL.Resolvers.InvoiceResolver
  alias CoreWeb.Helpers.InvoiceHelper
  alias CoreWeb.Utils.CommonFunctions

  def get_invoice_by_job(input) do
    case Invoices.get_invoice_by_job(input) do
      [] ->
        cond do
          InvoiceResolver.employee_verified?(input) ->
            create_invoice_from(Map.merge(%{is_quote: false}, input))

          input.cmr_id == input.user_id ->
            create_invoice_from(Map.merge(%{is_quote: true}, input))

          true ->
            {:error, ["you're not permitted!"]}
        end

      [invoice | _] ->
        if InvoiceResolver.valid_for_get_invoice?(input) do
          case send_invoice(invoice, input) do
            {:ok, invoice} ->
              if InvoiceResolver.employee_verified?(input) and input.job_status_id == "completed" do
                Invoices.update_invoice(invoice, %{adjust: true, is_quote: false})
              else
                {:ok, invoice}
              end

            {:error, error} ->
              {:error, error}
          end
        else
          {:error, ["you're not permitted!"]}
        end
    end
  end

  defp send_invoice(invoice, params) do
    case get_settings(params) do
      {:ok, %{max_allowed_tax: max_allowed_tax, max_allowed_discount: max_allowed_discount}} ->
        discounts = keys_to_atoms(invoice.discounts)
        taxes = keys_to_atoms(invoice.taxes)
        amounts = keys_to_atoms(invoice.amounts)
        discounts = add_discount_value(discounts, amounts)
        taxes = add_tax_value(taxes, amounts)

        invoice =
          Map.merge(invoice, %{
            max_allowed_discount: max_allowed_discount,
            invoice_date: invoice.inserted_at,
            max_allowed_tax: max_allowed_tax,
            taxes: taxes,
            discounts: discounts,
            amounts: amounts
          })
          |> InvoiceResolver.add_insurance_and_booking_percentage()

        {
          :ok,
          invoice
          #          CurrencyConversions.update_currency_fields(invoice, %{branch_id: params[:branch_id]})
        }

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["In settings table fields doesn't have valid keys"],
          __ENV__.line
        )
    end
  end

  def create_invoice_from(input) do
    with {:ok, _last, all} <- InvoiceHelper.create_invoice_from(input),
         %{invoice: data} <- all do
      {:ok, data}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  defp calculate_taxable_and_discountable_amounts(amounts) do
    discountable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.discount_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    taxable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.tax_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    %{discountable_price: discountable_amount, taxable_price: taxable_amount}
  end

  def get_settings(%{branch_id: branch_id}) do
    case Settings.get_settings_by(%{
           type: "branch",
           branch_id: branch_id,
           slug: ["max_allowed_discount", "max_allowed_tax"]
         }) do
      [] ->
        {:error, ["Branch Settings for max allowed Taxes and Discounts doesn't exit!"]}

      branch_settings ->
        branch_settings = Enum.map(branch_settings, & &1.fields)
        branch_settings = Enum.reduce(branch_settings, %{}, &Map.merge(&1, &2))
        branch_settings = keys_to_atoms(branch_settings)
        {:ok, branch_settings}
    end
  end

  #  check max taxes as whole, like sum of all taxes must not exceed from defined limit
  def check_max_tax(taxes, %{max_allowed_tax: max_allowed_tax}, %{taxable_price: taxable_amount}) do
    if max_allowed_tax[:allow] do
      if max_allowed_tax[:is_percentage] do
        taxes_percentage_value =
          Enum.reduce(taxes, 0, fn tax, acc ->
            cond do
              tax.is_percentage ->
                tax.value + acc

              tax.is_percentage == false ->
                tax.value * 100 / taxable_amount + acc

              true ->
                acc
            end
          end)

        Enum.map(taxes, fn tax ->
          if taxes_percentage_value > max_allowed_tax.max_value do
            Map.merge(tax, %{value: max_allowed_tax.max_value})
          else
            Map.merge(tax, %{value: tax.value})
          end
        end)
      else
        taxes_value =
          Enum.reduce(taxes, 0, fn tax, acc ->
            cond do
              tax.is_percentage -> tax.value / 100 * taxable_amount + acc
              tax.is_percentage == false -> tax.value + acc
              true -> acc
            end
          end)

        Enum.map(taxes, fn tax ->
          if taxes_value > max_allowed_tax.max_value do
            Map.merge(tax, %{value: max_allowed_tax.max_value})
          else
            Map.merge(tax, %{value: tax.value})
          end
        end)
      end
    else
      taxes
    end
  end

  #   check max taxes as individual like each tax will not excceed defined limit
  #  defp check_max_tax(taxes, %{max_allowed_tax: max_allowed_tax} = settings) do
  #    taxes = Enum.map(taxes, fn tax ->
  #      if max_allowed_tax.allow do
  #        cond do
  #          tax.is_percentage and max_allowed_tax.is_percentage and tax.value > max_allowed_tax.max_value ->
  #            tax = Map.merge(tax, %{value: max_allowed_tax.max_value})
  #          tax.is_percentage == false and max_allowed_tax.is_percentage == false
  #          and tax.value > max_allowed_tax.max_value ->
  #            tax = Map.merge(tax, %{value: max_allowed_tax.max_value})
  #          true -> tax
  #        end
  #      else
  #        tax
  #      end
  #    end)
  #  end
  def check_max_tax(taxes, _, _) do
    taxes
  end

  #  check max discounts as whole, like sum of all discounts must not exceed from defined limit
  def check_max_discount(discounts, %{max_allowed_discount: max_allowed_discount}, %{
        discountable_price: discountable_amount
      }) do
    if max_allowed_discount[:allow] do
      if max_allowed_discount[:is_percentage] do
        discounts_percentage_value =
          Enum.reduce(discounts, 0, fn discount, acc ->
            cond do
              discount.is_percentage ->
                discount.value + acc

              discount.is_percentage == false ->
                discount.value * 100 / discountable_amount + acc

              true ->
                acc
            end
          end)

        Enum.map(discounts, fn discount ->
          if discounts_percentage_value > max_allowed_discount.max_value do
            Map.merge(discount, %{value: max_allowed_discount.max_value})
          else
            Map.merge(discount, %{value: discount.value})
          end
        end)
      else
        discounts_value =
          Enum.reduce(discounts, 0, fn discount, acc ->
            cond do
              discount.is_percentage -> discount.value / 100 * discountable_amount + acc
              discount.is_percentage == false -> discount.value + acc
              true -> acc
            end
          end)

        Enum.map(discounts, fn discount ->
          if discounts_value > max_allowed_discount.max_value do
            Map.merge(discount, %{value: max_allowed_discount.max_value})
          else
            Map.merge(discount, %{value: discount.value})
          end
        end)
      end
    else
      discounts
    end
  end

  #  defp check_max_discount(discounts, %{max_allowed_discount: max_allowed_discount} = settings) do
  #    discounts = Enum.map(discounts, fn discount ->
  #      if max_allowed_discount.allow do
  #        cond do
  #          discount.is_percentage and max_allowed_discount.is_percentage and discount.value > max_allowed_discount.max_value ->
  #            discount = Map.merge(discount, %{value: max_allowed_discount.max_value})
  #          discount.is_percentage == false and max_allowed_discount.is_percentage == false
  #          and discount.value > max_allowed_discount.max_value ->
  #            discount = Map.merge(discount, %{value: max_allowed_discount.max_value})
  #          true -> discount
  #        end
  #      else
  #        discount
  #      end
  #    end)
  #  end
  def check_max_discount(discounts, _, _) do
    discounts
  end

  def update_invoice(
        %{amounts: input_amounts, taxes: input_taxes, discounts: input_discounts} = params
      ) do
    case get_settings(params) do
      {:ok, %{max_allowed_tax: _, max_allowed_discount: _} = settings} ->
        amounts =
          Enum.filter(input_amounts, &(Map.has_key?(&1, :service_id) == false))
          |> Enum.uniq_by(& &1.service_title)

        job_amount = [
          %{
            unit_price: params.unit_price,
            quantity: 1,
            service_id: params.service_id,
            service_title: params.service_name,
            discount_eligibility: true,
            tax_eligibility: true
          }
        ]

        amounts =
          (job_amount ++ amounts)
          |> rounding_charges_value()

        params = Map.merge(params, calculate_taxable_and_discountable_amounts(amounts))
        default_taxes = Enum.filter(input_taxes, & &1[:default])

        input_taxes =
          Enum.reject(input_taxes, & &1[:default])
          |> Enum.uniq_by(& &1.title)
          |> check_max_tax(settings, params)

        input_promotions =
          Enum.reject(input_discounts, &Map.has_key?(&1, :id))
          |> Enum.uniq_by(& &1.title)
          |> check_max_discount(settings, params)

        with true <- bsp_allowed_to_add_discounts(params.branch_id, input_promotions),
             true <- bsp_allowed_to_add_taxes(params.branch_id, input_taxes) do
          #          taxes = Enum.map(Taxes.get_taxes_by(params), & Map.from_struct(&1)) |> clean_taxes()
          taxes =
            (default_taxes ++ input_taxes)
            |> rounding_taxes_value()

          #          default_promotions = Enum.map(PromotionController.get_promotions_by(params), & Map.from_struct(&1))
          #                       |> Enum.map(& Map.drop(&1, [:__meta__, :promotion_status, :discount_type]))

          default_promotions =
            Enum.filter(input_discounts, &Map.has_key?(&1, :id))
            |> Enum.uniq_by(& &1.id)

          promotions =
            (default_promotions ++ input_promotions)
            |> rounding_promotions_value()

          update_invoice_by(promotions, taxes, amounts, params[:branch_id])
        else
          {:error, error} ->
            {:error, error}

          exception ->
            logger(
              __MODULE__,
              exception,
              ["Unexpected error occurred during Service Provider adding Taxes and Discounts"],
              __ENV__.line
            )
        end

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["In settings table fields doesn't have valid keys"],
          __ENV__.line
        )
    end
  end

  def update_invoice(%{amounts: input_amounts, discounts: input_discounts} = params) do
    case get_settings(params) do
      {:ok, %{max_allowed_tax: _, max_allowed_discount: _} = settings} ->
        amounts =
          Enum.filter(input_amounts, &(Map.has_key?(&1, :service_id) == false))
          |> Enum.uniq_by(& &1.service_title)

        job_amount = [
          %{
            unit_price: params.unit_price,
            quantity: 1,
            service_id: params.service_id,
            service_title: params.service_name,
            discount_eligibility: true,
            tax_eligibility: true
          }
        ]

        amounts =
          (job_amount ++ amounts)
          |> rounding_charges_value()

        params = Map.merge(params, calculate_taxable_and_discountable_amounts(amounts))

        input_promotions =
          Enum.reject(input_discounts, &Map.has_key?(&1, :id))
          |> Enum.uniq_by(& &1.title)
          |> check_max_discount(settings, params)

        case bsp_allowed_to_add_discounts(params.branch_id, input_promotions) do
          true ->
            #          default_promotions = Enum.map(PromotionController.get_promotions_by(params), & Map.from_struct(&1))
            #                       |> Enum.map(& Map.drop(&1, [:__meta__, :promotion_status, :discount_type]))
            default_promotions =
              Enum.filter(input_discounts, &Map.has_key?(&1, :id))
              |> Enum.uniq_by(& &1.id)

            promotions =
              (default_promotions ++ input_promotions)
              |> rounding_promotions_value()

            taxes =
              Enum.map(Taxes.get_taxes_by(params), &Map.from_struct(&1))
              |> clean_taxes()
              |> rounding_taxes_value()

            update_invoice_by(promotions, taxes, amounts, params[:branch_id])

          {:errro, error} ->
            {:error, error}

          exception ->
            logger(
              __MODULE__,
              exception,
              ["Unexpected error occurred during Service Provider adding Discounts"],
              __ENV__.line
            )
        end

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["In settings table fields doesn't have valid keys"],
          __ENV__.line
        )
    end
  end

  def update_invoice(%{amounts: input_amounts, taxes: input_taxes} = params) do
    case get_settings(params) do
      {:ok, %{max_allowed_tax: _, max_allowed_discount: _} = settings} ->
        amounts =
          Enum.filter(input_amounts, &(Map.has_key?(&1, :service_id) == false))
          |> Enum.uniq_by(& &1.service_title)

        job_amount = [
          %{
            unit_price: params.unit_price,
            quantity: 1,
            service_id: params.service_id,
            service_title: params.service_name,
            discount_eligibility: true,
            tax_eligibility: true
          }
        ]

        amounts =
          (job_amount ++ amounts)
          |> rounding_charges_value()

        params = Map.merge(params, calculate_taxable_and_discountable_amounts(amounts))
        default_taxes = Enum.filter(input_taxes, & &1[:default])

        input_taxes =
          Enum.reject(input_taxes, & &1[:default])
          |> Enum.uniq_by(& &1.title)
          |> check_max_tax(settings, params)

        case bsp_allowed_to_add_taxes(params.branch_id, input_taxes) do
          true ->
            taxes =
              (default_taxes ++ input_taxes)
              |> rounding_taxes_value()

            promotions =
              Enum.map(PromotionController.get_promotions_by(params), &Map.from_struct(&1))
              |> Enum.map(&Map.drop(&1, [:__meta__, :promotion_status, :discount_type]))
              |> rounding_promotions_value()

            update_invoice_by(promotions, taxes, amounts, params[:branch_id])

          {:errro, error} ->
            {:error, error}

          exception ->
            logger(
              __MODULE__,
              exception,
              ["Unexpected error occurred during Service Provider adding Taxes"],
              __ENV__.line
            )
        end

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["In settings table fields doesn't have valid keys"],
          __ENV__.line
        )
    end
  end

  def update_invoice(%{amounts: input_amounts} = params) do
    amounts =
      Enum.filter(input_amounts, &(Map.has_key?(&1, :service_id) == false))
      |> Enum.uniq_by(& &1.service_title)

    job_amount = [
      %{
        unit_price: params.unit_price,
        quantity: 1,
        service_id: params.service_id,
        service_title: params.service_name,
        discount_eligibility: true,
        tax_eligibility: true
      }
    ]

    amounts =
      (job_amount ++ amounts)
      |> rounding_charges_value()

    params = Map.merge(params, calculate_taxable_and_discountable_amounts(amounts))

    taxes =
      Enum.map(Taxes.get_taxes_by(params), &Map.from_struct(&1))
      |> clean_taxes()
      |> rounding_taxes_value()

    promotions =
      Enum.map(PromotionController.get_promotions_by(params), &Map.from_struct(&1))
      |> Enum.map(&Map.drop(&1, [:__meta__, :promotion_status, :discount_type]))
      |> rounding_promotions_value()

    update_invoice_by(promotions, taxes, amounts, params[:branch_id])
  end

  defp update_invoice_by(discounts, taxes, amounts, _) do
    discounts = add_discount_value(discounts, amounts)
    taxes = add_tax_value(taxes, amounts)

    case calculate_final_amount(discounts, taxes, amounts) do
      {:ok, [final_amount, total_charges, total_discount, total_tax]} ->
        updated_invoice = %{
          final_amount: final_amount,
          total_tax: total_tax,
          total_discount: total_discount,
          total_charges: total_charges,
          amounts: amounts,
          discounts: discounts,
          taxes: taxes
        }

        {
          :ok,
          updated_invoice
          #          CurrencyConversions.update_currency_fields(updated_invoice, %{branch_id: branch_id})
        }

      {:error, error} ->
        {:error, error}
    end
  end

  def bsp_allowed_to_add_taxes(branch_id, taxes) do
    if taxes == [] do
      true
    else
      case Settings.get_settings_by(%{slug: "allow_bsp_to_add_tax", branch_id: branch_id}) do
        nil ->
          {:error, ["setting doesn't exist to verify BSP allowed to add taxes"]}

        %{fields: %{"add_tax" => true}} ->
          true

        %{fields: %{"add_tax" => false}} ->
          {:error, ["Service Provider not allowed to add Taxes"]}

        exception ->
          logger(
            __MODULE__,
            exception,
            ["Unexpected error occurred during Service Provider adding Taxes"],
            __ENV__.line
          )
      end
    end
  end

  def bsp_allowed_to_add_discounts(branch_id, discounts) do
    if discounts == [] do
      true
    else
      case Settings.get_settings_by(%{slug: "allow_bsp_to_add_discount", branch_id: branch_id}) do
        nil ->
          {:error, ["setting doesn't exist to verify BSP allowed to add discounts"]}

        %{fields: %{"add_discount" => true}} ->
          true

        %{fields: %{"add_discount" => false}} ->
          {:error, ["Service Provider not allowed to add Discounts"]}

        exception ->
          logger(
            __MODULE__,
            exception,
            ["Unexpected error occurred during Service Provider adding Discounts"],
            __ENV__.line
          )
      end
    end
  end

  def rounding_charges_value(amounts) do
    Enum.map(amounts, fn amount ->
      amount_value =
        if is_float(amount.unit_price),
          do: Float.round(amount.unit_price, 2),
          else: amount.unit_price

      Map.merge(amount, %{unit_price: amount_value})
    end)
  end

  def rounding_promotions_value(promotions) do
    Enum.map(promotions, fn promotion ->
      discount_value =
        if is_float(promotion.value), do: Float.round(promotion.value, 2), else: promotion.value

      Map.merge(promotion, %{value: discount_value})
    end)
  end

  def rounding_taxes_value(taxes) do
    Enum.map(taxes, fn tax ->
      tax_value = if is_float(tax.value), do: Float.round(tax.value, 2), else: tax.value
      Map.merge(tax, %{value: tax_value})
    end)
  end

  def add_discount_value(discounts, amounts) do
    discountable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.discount_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    discounts =
      Enum.map(discounts, fn discount ->
        if discount.is_percentage do
          discount_amount =
            (discount.value * discountable_amount / 100)
            |> Float.round(2)

          Map.merge(discount, %{amount: discount_amount})
        else
          discount_amount =
            if is_float(discount.value), do: Float.round(discount.value, 2), else: discount.value

          Map.merge(discount, %{amount: discount_amount})
        end
      end)

    discounts
  end

  def add_tax_value(taxes, amounts) do
    taxable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.tax_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    taxes =
      Enum.map(taxes, fn tax ->
        if tax.is_percentage do
          tax_amount = (tax.value * taxable_amount / 100) |> Float.round(2)
          Map.merge(tax, %{amount: tax_amount})
        else
          tax_amount = if is_float(tax.value), do: Float.round(tax.value, 2), else: tax.value
          Map.merge(tax, %{amount: tax_amount})
        end
      end)

    taxes
  end

  def generate_invoice(input) do
    with {:ok, _last, all} <- InvoiceHelper.generate_invoice(input),
         %{generate_invoice: data} <- all do
      {:ok, data}
    else
      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def adjust_invoice(input) do
    with %{is_quote: false} <- Invoices.get_invoice(input.id),
         {:ok, _last, %{adjust_invoice: data}} <- InvoiceHelper.adjust_invoice(input) do
      {:ok, data}
    else
      nil -> {:error, ["Invoice doesn't exist!"]}
      %{is_quote: true} = invoice -> adjust_invoice(invoice, input)
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def check_quote(%{id: id} = params) do
    case Invoices.get_invoice(id) do
      nil -> {:error, ["Invoice doesn't exist!"]}
      %{is_quote: true} = invoice -> adjust_invoice(invoice, params)
      %{is_quote: false} -> :ok
    end
  end

  defp adjust_invoice(invoice, params) do
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

  def calculate_final_amount(promotions, taxes, amounts) do
    total_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        a.unit_price * a.quantity + acc
      end)

    total_amount = if is_float(total_amount), do: Float.round(total_amount, 2), else: total_amount

    taxable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.tax_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    discountable_amount =
      Enum.reduce(amounts, 0, fn a, acc ->
        if a.discount_eligibility do
          a.unit_price * a.quantity + acc
        else
          acc
        end
      end)

    total_discount =
      Enum.reduce(promotions, 0, fn promotion, acc ->
        if promotion.is_percentage do
          promotion.value * discountable_amount / 100 + acc
        else
          promotion.value + acc
        end
      end)

    total_discount =
      if is_float(total_discount), do: Float.round(total_discount, 2), else: total_discount

    total_tax =
      Enum.reduce(taxes, 0, fn tax, acc ->
        if tax.is_percentage do
          tax.value * taxable_amount / 100 + acc
        else
          tax.value + acc
        end
      end)

    total_tax = if is_float(total_tax), do: Float.round(total_tax, 2), else: total_tax

    final_amount = total_amount - total_discount + total_tax
    final_amount = if is_float(final_amount), do: Float.round(final_amount, 2), else: final_amount
    if final_amount < 0, do: 0, else: final_amount

    {:ok, [final_amount, total_amount, total_discount, total_tax]}
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong in Invoice amount Calculation"],
        __ENV__.line
      )
  end

  def clean_taxes(taxes) do
    Enum.map(taxes, fn tax ->
      tax_type = tax.tax_type
      tax = Map.drop(tax, [:__meta__, :business, :tax_type_id])
      tax_type = %{id: tax_type.id, name: tax_type.name, slug: tax_type.slug}
      Map.merge(tax, %{tax_type: tax_type})
    end)
  end
end
