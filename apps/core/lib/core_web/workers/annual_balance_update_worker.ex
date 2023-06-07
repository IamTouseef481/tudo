defmodule CoreWeb.Workers.AnnualBalanceUpdateWorker do
  @moduledoc false
  alias Core.Payments

  def perform(branch_id) do
    case Payments.get_balance_by_branch(branch_id) do
      %{} = balance ->
        params = %{bsp_annual_earning: 0, bsp_annual_transfer: 0}

        case Payments.update_balance(balance, params) do
          {:ok, balance} -> {:ok, balance}
          {:error, _} -> {:error, ["error while updating balance"]}
        end

      _ ->
        {:error, ["error while getting balance"]}
    end

    time =
      DateTime.utc_now()
      |> CoreWeb.Utils.DateTimeFunctions.convert_utc_time_to_local_time()
      |> Timex.beginning_of_year()
      |> Timex.shift(years: 1)

    Exq.enqueue_at(
      Exq,
      "default",
      time,
      "CoreWeb.Workers.AnnualBalanceUpdateWorker",
      [branch_id]
    )
  end
end
