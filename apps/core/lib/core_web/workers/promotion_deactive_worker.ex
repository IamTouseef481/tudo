defmodule CoreWeb.Workers.PromotionDeactiveWorker do
  @moduledoc false
  import CoreWeb.Utils.Errors
  alias Core.Jobs.DashboardMetaHandler

  def perform(id) do
    case Core.Promotions.get_promotion(id) do
      nil ->
        {:ok, ["no promotion to be updated!"]}

      %{branch_id: branch_id} = promotion ->
        case Core.Promotions.update_promotion(promotion, %{promotion_status_id: "expired"}) do
          {:ok, data} ->
            DashboardMetaHandler.update_bsp_promotion_meta(branch_id)
            {:ok, data}

          all ->
            all
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["could not de active promotion"], __ENV__.line)
  end
end
