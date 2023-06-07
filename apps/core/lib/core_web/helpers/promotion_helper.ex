defmodule CoreWeb.Helpers.PromotionHelper do
  #   Core.Promotions.Promotion.Sages
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.{BSP, PaypalPayments, Promotions}
  alias Core.Jobs.DashboardMetaHandler
  alias Core.PaypalPayments.SubscriptionHandler, as: Common
  alias TudoChatWeb.Helpers.MessageHelper

  @common_error ["Enable to fetch Promotions"]

  def create_promotion(params) do
    new()
    |> run(:check_branch_approval, &check_branch_approval/2, &abort/3)
    |> run(:get_promotion_status, &get_promotion_status/2, &abort/3)
    |> run(:get_promotion, &get_promotion/2, &abort/3)
    |> run(:available_promotion, &validate_promotion/2, &abort/3)
    |> run(:promotion, &create_promotion/2, &abort/3)
    |> run(:subscription_usage, &update_subscription_usage/2, &abort/3)
    |> run(:bsp_meta, &create_bsp_meta_on_create_promotion/2, &abort/3)
    |> run(:create_message_on_promotion, &create_message_on_promotion_creation/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_promotion(params) do
    new()
    |> run(:promotion_exist, &promotion_exist/2, &abort/3)
    |> run(:validate_promotion_status, &validate_promotion_status/2, &abort/3)
    |> run(:promotion, &update_promotion/2, &abort/3)
    |> run(:bsp_meta, &update_bsp_meta_on_update_promotion/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # -----------------------------------------------

  defp get_promotion(_, params) do
    case Promotions.get_promotion_by(params) do
      [] -> {:ok, ["valid"]}
      _ -> {:error, ["Promotion already exist!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  defp check_branch_approval(_, %{branch_id: branch_id}) do
    case BSP.get_branch!(branch_id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{status_id: "confirmed"} = branch -> {:ok, branch}
      %{status_id: _} -> {:error, ["branch is not approved"]}
      _ -> {:error, ["unexpected error occurred"]}
    end
  end

  defp get_promotion_status(_, %{promotion_status_id: status}) do
    case Promotions.get_promotion_statuses(status) do
      nil -> {:error, ["Invalid Promotion status"]}
      %{} -> {:ok, ["valid"]}
      _ -> {:error, ["Invalid Promotion status"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  defp promotion_exist(_, %{id: id}) do
    case Promotions.get_promotion(id) do
      nil -> {:error, ["Promotion doesn't exist"]}
      %{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @common_error, __ENV__.line)
  end

  defp validate_promotion(_, %{
         radius: radius,
         begin_date: begin_date,
         end_date: _,
         branch_id: branch_id
       }) do
    %{business_id: business_id} = BSP.get_branch!(branch_id)

    case Promotions.get_available_promotions_for_creation(%{
           radius: radius,
           begin_date: begin_date,
           branch_id: branch_id
         }) do
      [] ->
        case Promotions.get_available_promotions_for_creation(%{
               radius: radius,
               begin_date: begin_date,
               business_id: business_id
             }) do
          [] -> {:error, ["No valid Promotion available against this data"]}
          [promotion | _remaining_promotions] -> updating_promotion_as_used(promotion)
        end

      [promotion | _remaining_promotions] ->
        updating_promotion_as_used(promotion)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["enable to validate promotion"], __ENV__.line)
  end

  defp validate_promotion(_, _) do
    {:error, ["something missing in params for promotion validation"]}
  end

  defp updating_promotion_as_used(promotion) do
    case Promotions.update_available_promotion(promotion, %{used_at: DateTime.utc_now()}) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Something went wrong calculating Promotion usage"]}
    end
  end

  defp create_promotion(_, %{rest_photos: rest_photos, end_date: end_date} = params) do
    params = Map.merge(params, %{photos: rest_photos})

    case Promotions.create_promotion(params) do
      {:ok, data} ->
        Exq.enqueue_at(
          Exq,
          "default",
          end_date,
          #          Timex.shift(
          #            DateTime.utc_now(),
          #            seconds: Timex.diff(end_date, DateTime.utc_now, :seconds)
          #          ),
          "CoreWeb.Workers.PromotionDeactiveWorker",
          [
            data.id
          ]
        )

        #        create_message_on_promotion_creation(data)
        {:ok, data}

      all ->
        all
    end
  end

  defp create_promotion(_, %{photos: photos, end_date: end_date} = params) do
    files = CoreWeb.Controllers.ImageController.upload(photos, "services")
    params = Map.merge(params, %{photos: files})

    case Promotions.create_promotion(params) do
      {:ok, data} ->
        Exq.enqueue_at(
          Exq,
          "default",
          end_date,
          #          Timex.shift(
          #            DateTime.utc_now(),
          #            seconds: Timex.diff(end_date, DateTime.utc_now, :seconds)
          #          ),
          "CoreWeb.Workers.PromotionDeactiveWorker",
          [
            data.id
          ]
        )

        {:ok, data}

      all ->
        all
    end
  end

  defp create_promotion(_, _) do
    {:ok, :not_applicable}
  end

  #  Asynchronous call for send messages during  promotion creation.
  defp create_message_on_promotion_creation(
         %{
           promotion: %{
             id: id,
             title: title,
             description: description,
             photos: photos,
             branch_id: branch_id
           }
         },
         _
       ) do
    params = %{
      id: id,
      title: title,
      description: description,
      photos: photos,
      branch_id: branch_id
    }

    Task.start(
      __MODULE__,
      :create_message_on_promotion_creation_task,
      params: params
    )
  end

  def create_message_on_promotion_creation_task(
        {_,
         %{id: _, title: title, description: description, photos: photos, branch_id: branch_id}}
      ) do
    branch_location = Core.BSP.get_branch_location(branch_id)
    user_ids_by_location = Core.Leads.get_leads_by_location_for_marketing_group(branch_location)
    user_ids_by_city = Core.Accounts.get_leads_by_city_for_marketing_group(branch_location)
    user_ids = Enum.uniq(user_ids_by_location ++ user_ids_by_city)
    group_ids = apply(TudoChat.Groups, :get_group_by_user_id, [user_ids])
    #    implmentation for getting user ids by using one function.
    #    group_ids = Core.BSP.get_branch_location(branch_id)
    #    |> Core.Leads.get_leads_by_location_for_marketing_group()
    #    |> List.flatten()
    #    |> Enum.uniq()
    #    |> Enum.filter(fn x -> x != nil end)
    #    |> TudoChat.Groups.get_group_by_user_id()
    message_body =
      cond do
        is_binary(title) and is_binary(description) -> title <> ", " <> description
        is_binary(description) -> description
        is_binary(title) -> title
        true -> ""
      end

    message_image =
      case photos do
        [image | _] -> image
        _ -> nil
      end

    messages =
      Enum.reduce(group_ids, [], fn group_id, acc ->
        params = %{
          marketing_group: true,
          group_id: group_id,
          message: message_body,
          message_file: message_image,
          is_send_notification: false
        }

        case apply(MessageHelper, :create_com_group_message, [params]) do
          {:ok, _, %{message: %{id: message_id} = msg}} ->
            Exq.enqueue_in(
              Exq,
              "default",
              15,
              #            2592000 #30days
              "CoreWeb.Workers.DeleteMarketingChatGroupWorker",
              [message_id]
            )

            [msg | acc]

          err ->
            logger(__MODULE__, err, :info, __ENV__.line)
            acc
        end
      end)

    {:ok, messages}
  end

  defp update_subscription_usage(
         %{
           available_promotion: %{additional: false},
           check_branch_approval: %{business_id: business_id}
         },
         %{branch_id: _branch_id}
       ) do
    case PaypalPayments.get_paypal_subscription_by_business(business_id) do
      [] ->
        {:error, ["Promotion can't Created. Please Upgrade Your Plan"]}

      [%{promotions: promotions, annual: annual} = subscription | _] ->
        Common.updated_subscription_usage(subscription, annual, %{promotions: promotions})
    end
  end

  defp update_subscription_usage(_, _) do
    {:ok, ["additional purchased promotion not need to update subscription"]}
  end

  defp create_bsp_meta_on_create_promotion(_, %{branch_id: branch_id}) do
    case DashboardMetaHandler.update_bsp_promotion_meta(branch_id) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp validate_promotion_status(%{promotion_exist: %{end_date: end_date}}, %{
         promotion_status_id: "active"
       }) do
    if DateTime.compare(DateTime.utc_now(), end_date) == :lt do
      {:ok, ["valid"]}
    else
      {:error, ["Promotion expired"]}
    end
  end

  defp validate_promotion_status(_, _), do: {:ok, ["valid"]}

  defp update_promotion(%{promotion_exist: promotion}, %{rest_photos: rest_photos} = params) do
    params = Map.merge(params, %{photos: rest_photos})

    case Promotions.update_promotion(promotion, params) do
      {:ok, data} ->
        #        Exq.enqueue(Exq, "default", "CoreWeb.Workers.NotifyWorker", [:provider_approved, 1])
        {:ok, data}

      all ->
        all
    end
  end

  defp update_promotion(%{promotion_exist: promotion}, %{photos: photos} = params) do
    files = CoreWeb.Controllers.ImageController.upload(photos, "services")
    params = Map.merge(params, %{photos: files})

    case Promotions.update_promotion(promotion, params) do
      {:ok, data} ->
        #        Exq.enqueue(Exq, "default", "CoreWeb.Workers.NotifyWorker", [:provider_approved, 1])
        {:ok, data}

      all ->
        all
    end
  end

  defp update_promotion(%{promotion_exist: promotion}, params) do
    case Promotions.update_promotion(promotion, params) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
      all -> all
    end
  end

  defp update_promotion(_, _) do
    {:ok, :not_applicable}
  end

  defp update_bsp_meta_on_update_promotion(%{promotion: %{branch_id: branch_id}}, %{
         promotion_status_id: _
       }) do
    case DashboardMetaHandler.update_bsp_promotion_meta(branch_id) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  defp update_bsp_meta_on_update_promotion(_, _) do
    {:ok, ["valid"]}
  end
end
