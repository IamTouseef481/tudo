defmodule CoreWeb.GraphQL.Resolvers.NotificationResolver do
  @moduledoc false
  alias Core.Notifications

  def get_push_notifications_by_user_role(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})
    {:ok, Notifications.get_push_notifications_by_user_role(input)}
  end

  def update_push_notifications(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    notifications =
      Enum.reduce(input.notification_ids, [], fn id, acc ->
        case Notifications.get_unread_push_notification(id) do
          %{} = noti -> updates_push_notification(noti, input, acc)
          _ -> acc
        end
      end)

    count = Enum.count(notifications)
    CoreWeb.Workers.NotifyWorker.update_cmr_meta(List.first(notifications), -count)
    CoreWeb.Workers.NotifyWorker.update_bsp_meta(List.first(notifications), -count)
    {:ok, notifications}
  end

  defp updates_push_notification(notification, attrs, acc) do
    case Notifications.update_push_notification(notification, attrs) do
      {:ok, noti} -> [noti | acc]
      _ -> acc
    end
  end

  def get_admin_email_notification_settings(_, _, %{context: %{current_user: current_user}}) do
    if "web" in current_user.acl_role_id do
      {:ok, Notifications.list_admin_notification_settings()}
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def update_admin_email_notification_settings(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      case Notifications.get_admin_notification_setting(id) do
        nil -> {:error, ["Setting does not exist"]}
        %{} = setting -> Notifications.update_admin_notification_setting(setting, input)
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end
end
