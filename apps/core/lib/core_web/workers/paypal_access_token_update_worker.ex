defmodule CoreWeb.Workers.PaypalAccessTokenUpdateWorker do
  @moduledoc false
  import CoreWeb.Utils.{Errors}
  alias Core.PaypalPayments

  def perform do
    expires_in =
      case PaypalPayments.get_paypal_access_token_for_update() do
        %{} = attr ->
          case CoreWeb.Controllers.PaypalPaymentController.get_paypal_access_token() do
            {:ok, %{access_token: access_token, expires_in: expires_in}} ->
              case PaypalPayments.update_paypal_access_attributes(attr, %{
                     access_token: access_token
                   }) do
                {:ok, _attr} -> {:ok, expires_in}
                {:error, _} -> {:ok, expires_in}
              end

            {:error, error} ->
              {:error, error}
          end

        _ ->
          {:error, ["error while getting attributes"]}
      end

    expires_in =
      case expires_in do
        {:ok, expires_in} when is_integer(expires_in) -> expires_in
        _ -> 32_400
      end

    Exq.enqueue_in(
      Exq,
      "default",
      expires_in,
      "CoreWeb.Workers.PaypalAccessTokenUpdateWorker",
      []
    )
  rescue
    exception ->
      logger(__MODULE__, exception, [""], __ENV__.line)
  end
end
