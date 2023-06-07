defmodule CoreWeb.Workers.SubscriptionPaymentValidationWorker do
  @moduledoc false

  import CoreWeb.Utils.Errors

  alias Core.Payments
  alias CoreWeb.Helpers.BtSubscriptionHelper, as: SubHelper

  def perform(sub_id) do
    [local_subscription] = Payments.get_brain_tree_subscription_by(%{subscription_id: sub_id})

    case Braintree.Subscription.find(sub_id) do
      {:ok,
       %{
         status: status,
         number_of_billing_cycles: number_of_billing_cycles,
         current_billing_cycle: current_billing_cycle,
         never_expires: never_expires
       } = _subscription} ->
        update_subscription_status(
          status,
          number_of_billing_cycles,
          current_billing_cycle,
          never_expires,
          local_subscription,
          sub_id
        )

      {:error, _} ->
        {:error, ["Unable to fetch Braintree Subscription"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      {:ok, ["error in worker"]}
  end

  def update_subscription_status(
        status,
        number_of_billing_cycles,
        current_billing_cycle,
        never_expires,
        local_subscription,
        sub_id
      ) do
    case status do
      "Active" ->
        Payments.update_brain_tree_subscription(local_subscription, %{status_id: "active"})

        check_for_next_cycle(
          number_of_billing_cycles,
          current_billing_cycle,
          never_expires,
          sub_id
        )

      "Past Due" ->
        Payments.update_brain_tree_subscription(local_subscription, %{status_id: "past_due"})

        check_for_next_cycle(
          number_of_billing_cycles,
          current_billing_cycle,
          never_expires,
          sub_id
        )

      status ->
        Payments.update_brain_tree_subscription(
          local_subscription,
          %{status_id: String.downcase(status)}
        )
    end
  end

  def check_for_next_cycle(number_of_billing_cycles, current_billing_cycle, never_expires, sub_id) do
    if never_expires do
      SubHelper.payment_validation_on_each_billing_cycle(%{bt_subscription: %{id: sub_id}}, "")
    else
      if current_billing_cycle < number_of_billing_cycles do
        SubHelper.payment_validation_on_each_billing_cycle(
          %{bt_subscription: %{id: sub_id}},
          ""
        )
      else
        {:ok, ["billing cycles are completed"]}
      end
    end
  end
end
