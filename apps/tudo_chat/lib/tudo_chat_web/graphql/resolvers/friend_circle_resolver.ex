defmodule TudoChatWeb.GraphQL.Resolvers.FriendCircleResolver do
  @moduledoc false
  use TudoChatWeb.GraphQL, :resolver
  alias TudoChat.FriendCircles
  alias TudoChatWeb.Controllers.FriendCircleController

  @default_error ["unexpected error occurred"]

  def friend_circle_statuses(_, _, _) do
    {:ok, FriendCircles.list_friend_circle_statuses()}
  end

  def create_friend_circle_status(_, %{input: input}, _) do
    case FriendCircles.get_friend_circle_status(input.id) do
      nil ->
        case FriendCircles.create_friend_circle_status(input) do
          {:ok, member} -> {:ok, member}
          {:error, error} -> {:error, error}
          _ -> {:error, ["error occurred while creating friend circle status!"]}
        end

      _data ->
        {:error, ["friend circle status already exists!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_friend_circle_status(_, %{input: input}, _) do
    case FriendCircles.get_friend_circle_status(input.id) do
      nil ->
        {:error, ["friend circle status doesn't exist!"]}

      %{} = status ->
        case FriendCircles.update_friend_circle_status(status, input) do
          {:ok, status} -> {:ok, status}
          {:error, error} -> {:error, error}
          _ -> {:error, ["something went wrong"]}
        end

      _ ->
        {:error, ["something went wrong"]}
    end
  end

  def delete_friend_circle_status(_, %{input: input}, _) do
    case FriendCircles.get_friend_circle_status(input.id) do
      nil ->
        {:error, ["friend circle status doesn't exist!"]}

      %{} = status ->
        case FriendCircles.delete_friend_circle_status(status) do
          {:ok, status} -> {:ok, status}
          {:error, error} -> {:error, error}
          _ -> {:error, ["something went wrong"]}
        end

      _ ->
        {:error, ["something went wrong"]}
    end
  end

  def friend_circles(_, _, _) do
    {:ok, FriendCircles.list_friend_circles()}
  end

  def create_friend_circle(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_from_id: current_user.id, status_id: "pending"})

    case Core.Accounts.get_user!(input.user_to_id) do
      nil -> {:error, ["user_to_id doesn't exist!"]}
      %{} -> FriendCircleController.create_friend_circle(input)
      _ -> {:error, ["error occurred while getting user"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_friend_circle(_, %{input: %{status_id: _, id: _} = input}, %{
        context: %{current_user: _current_user}
      }) do
    #    input = Map.merge(input, %{user_from_id: current_user.id})
    case FriendCircleController.update_friend_circle(input) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, error}
    end
  end

  def get_friend_circle(_, %{input: %{id: id} = _input}, %{
        context: %{current_user: _current_user}
      }) do
    #    input = Map.merge(input, %{user_from_id: current_user.id})
    case FriendCircles.get_friend_circle(id) do
      nil -> {:error, ["friend request doesn't exist!"]}
      %{} = circle -> {:ok, circle}
      _ -> {:error, ["something went wrong"]}
    end
  end

  def get_friend_circle_by_sender(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_from_id: current_user.id})

    case FriendCircles.get_friend_circle_by(input) do
      [] -> {:error, ["friend request doesn't exist!"]}
      %{} = circles -> {:ok, circles}
      _ -> {:error, ["something went wrong"]}
    end
  end

  def get_friend_circle_by_receiver(_, _, %{context: %{current_user: current_user}}) do
    input = %{user_to_id: current_user.id}

    case FriendCircles.get_friend_circle_by(input) do
      [] -> {:error, ["friend request doesn't exist!"]}
      circles -> {:ok, circles}
    end
  end

  def delete_friend_circle(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_from_id: current_user.id})

    case FriendCircles.get_friend_circle(input.id) do
      nil ->
        {:error, ["friend request doesn't exist!"]}

      %{} = circle ->
        case FriendCircles.delete_friend_circle(circle) do
          {:ok, circle} -> {:ok, circle}
          {:error, error} -> {:error, error}
          _ -> {:error, ["something went wrong"]}
        end

      _ ->
        {:error, ["something went wrong"]}
    end
  end
end
