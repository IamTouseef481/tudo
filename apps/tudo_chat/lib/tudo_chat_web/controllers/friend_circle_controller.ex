defmodule TudoChatWeb.Controllers.FriendCircleController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.{FriendCircles, Groups}
  alias TudoChatWeb.Helpers.FriendCircleHelper

  @default_error ["unexpected error occurred!"]

  def update_friend_circle(input) do
    with {:ok, _last, all} <- FriendCircleHelper.update_friend_circle(input),
         %{friend_circle: friend_circle, updated_group_member: _member} <- all do
      {:ok, friend_circle}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_friend_circle(input) do
    case FriendCircles.get_friend_circle_by(input) do
      [] ->
        case FriendCircles.create_friend_circle(input) do
          {:ok, request} ->
            send_notification_and_email(request)
            {:ok, request}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["error occurred while creating friend circle!"]}
        end

      circles ->
        case FriendCircles.update_friend_circle(List.last(circles), input) do
          {:ok, request} ->
            send_notification_and_email(request)
            {:ok, request}

          {:error, error} ->
            {:error, error}

          _ ->
            {:error, ["error occurred while creating friend circle!"]}
        end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["something went wrong"], __ENV__.line)
  end

  def send_notification_and_email(%{user_to_id: user_to_id, group_id: group_id}) do
    group_name =
      if is_nil(group_id) do
        ""
      else
        case Groups.get_group(group_id) do
          %{name: name} -> name
          _ -> ""
        end
      end

    case Core.Accounts.get_user!(user_to_id) do
      %{email: email, profile: %{"first_name" => first_name, "last_name" => last_name}} ->
        Exq.enqueue(
          Exq,
          "default",
          Core.Workers.NotifyWorker,
          [
            [user_to_id],
            "New invitation received from #{first_name} #{last_name} in group #{group_name}"
          ]
        )

        Exq.enqueue(
          Exq,
          "default",
          "TudoChat.Core.Workers.NotificationEmailsWorker",
          [
            "friend_request",
            %{email: email, language: "en", name: first_name <> " " <> last_name}
          ]
        )
    end
  end
end
