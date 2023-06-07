defmodule CoreWeb.Utils.CurrencyConversions do
  @moduledoc """
    Module For Converting Currency values from one currency to another.
    The default standard value is dollar.
  """
  import CoreWeb.Utils.Errors
  alias Core.Regions
  alias CoreWeb.Utils.CommonFunctions

  @api_key "bb44f43c-95f9-4edc-9525-0c66b323c5a1"
  @headers [
    {"Accept", "application/json"},
    {"Content-Type", "application/json"},
    {"apiKey", @api_key}
  ]
  @float_keys [
    :price,
    :amount,
    :cost,
    :value,
    :bsp_pending_balance,
    :bsp_available_balance,
    :bsp_cash_earning,
    :bsp_annual_earning,
    :bsp_total_earning,
    :bsp_annual_transfer,
    :bsp_total_transfer,
    :tudo_balance,
    :tudo_due_amount,
    :cmr_spent_amount,
    :bsp_spent_amount,
    :payout_fee,
    :pay_due_amount,
    :paid_amount,
    :final_amount,
    :returned_amount,
    :cheque_amount,
    :total_charges,
    :total_discount,
    :total_tax,
    :initial_cost,
    :cost_at_working,
    :cost_at_complete,
    :basic_fee,
    :item_fee,
    :fee,
    :invoice_amount,
    :bsp_amount,
    :tudo_booking_charges,
    :tudo_commission_charges,
    :insurance_amount,
    :brain_tree_fee,
    :bsp_tip_amount,
    :tudo_tip_amount,
    :total_tip_amount,
    :cancellation_fee,
    :chargebacks,
    :govt_fee,
    :donation_amount,
    :tudo_reserve_amount,
    :bsp_total_amount,
    :tudo_total_amount,
    :tudo_total_deducted_amount,
    :total_transaction_amount,
    :monthly_price,
    :annual_price,
    :base_price,
    :promotion_cost,
    :promotion_total_cost,
    :expire_after_amount,
    :valid_after_amount,
    :package_monthly_price,
    :package_annual_price,
    :additional_branch_office_charges,
    :additional_employee_charges,
    :additional_tenant_business_charges,
    :additional_promotion_charges,
    :additional_job_posting_charges
  ]

  #  @json_keys [
  #    :amount,
  #    :amounts,
  #    :discounts,
  #    :taxes,
  #    :additional_fees,
  #    :donations,
  #    :plan_discount,
  #    :gratuity,
  #    :fields
  #  ]

  def get_currencies_by_countries do
    url = "https://api.cloudmersive.com/currency/exchange-rates/list-available"

    case HTTPoison.post(url, "{}", @headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"Currencies" => currencies}} -> {:ok, currencies}
          _ -> {:error, ["Exchange Rate not found"]}
        end

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      _ ->
        {:error, ["Bad response from APi"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def get_currency_rate(source, destination) do
    url = "https://api.cloudmersive.com/currency/exchange-rates/get/#{source}/to/#{destination}"

    case HTTPoison.post(url, "{}", @headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"ExchangeRate" => rate}} -> {:ok, rate}
          _ -> {:error, ["Exchange Rate not found"]}
        end

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      {:ok, %{status_code: 400, body: body}} ->
        {:error, body}

      _ ->
        {:error, ["Bad response from APi"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
  end

  def convert_currency(source, destination, amount) do
    url =
      "https://api.cloudmersive.com/currency/exchange-rates/convert/#{source}/to/#{destination}"

    case HTTPoison.post(url, "#{amount}", @headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"ConvertedPrice" => rate}} -> {:ok, rate}
          _ -> {:error, ["Currency not converted"]}
        end

      {:ok, %{status_code: 401}} ->
        {:error, ["Unauthorized for API"]}

      _ ->
        {:error, ["Bad response from APi"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong"], __ENV__.line)
  end

  def update_currency_fields(model, country_id, source \\ "USD") do
    model = if is_struct(model), do: Map.from_struct(model), else: model

    case Regions.get_countries(country_id) do
      %{currency_code: currency_code} ->
        if source != currency_code do
          rate =
            case get_currency_rate(source, currency_code) do
              {:ok, rate} -> rate
              {:error, _} -> 1
            end

          Enum.reduce(model, model, fn {field, value}, acc ->
            if field in @float_keys and is_number(value) do
              Map.put(acc, field, CommonFunctions.round_off_value(value * rate))
            else
              acc
            end
          end)
        else
          model
        end

      _ ->
        model
    end

    #    rescue
    #    a ->
    #      model
  end
end
