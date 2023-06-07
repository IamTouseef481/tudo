defmodule TudoChat.FriendCirclesTest do
  use TudoChat.DataCase

  alias TudoChat.FriendCircles

  describe "friends_circle" do
    alias TudoChat.FriendCircles.FriendCircle

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def friend_circle_fixture(attrs \\ %{}) do
      {:ok, friend_circle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> FriendCircles.create_friend_circle()

      friend_circle
    end

    test "list_friends_circle/0 returns all friends_circle" do
      friend_circle = friend_circle_fixture()
      assert FriendCircles.list_friends_circle() == [friend_circle]
    end

    test "get_friend_circle!/1 returns the friend_circle with given id" do
      friend_circle = friend_circle_fixture()
      assert FriendCircles.get_friend_circle!(friend_circle.id) == friend_circle
    end

    test "create_friend_circle/1 with valid data creates a friend_circle" do
      assert {:ok, %FriendCircle{} = friend_circle} =
               FriendCircles.create_friend_circle(@valid_attrs)

      assert friend_circle.description == "some description"
      assert friend_circle.id == "some id"
    end

    test "create_friend_circle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FriendCircles.create_friend_circle(@invalid_attrs)
    end

    test "update_friend_circle/2 with valid data updates the friend_circle" do
      friend_circle = friend_circle_fixture()

      assert {:ok, %FriendCircle{} = friend_circle} =
               FriendCircles.update_friend_circle(friend_circle, @update_attrs)

      assert friend_circle.description == "some updated description"
      assert friend_circle.id == "some updated id"
    end

    test "update_friend_circle/2 with invalid data returns error changeset" do
      friend_circle = friend_circle_fixture()

      assert {:error, %Ecto.Changeset{}} =
               FriendCircles.update_friend_circle(friend_circle, @invalid_attrs)

      assert friend_circle == FriendCircles.get_friend_circle!(friend_circle.id)
    end

    test "delete_friend_circle/1 deletes the friend_circle" do
      friend_circle = friend_circle_fixture()
      assert {:ok, %FriendCircle{}} = FriendCircles.delete_friend_circle(friend_circle)

      assert_raise Ecto.NoResultsError, fn ->
        FriendCircles.get_friend_circle!(friend_circle.id)
      end
    end

    test "change_friend_circle/1 returns a friend_circle changeset" do
      friend_circle = friend_circle_fixture()
      assert %Ecto.Changeset{} = FriendCircles.change_friend_circle(friend_circle)
    end
  end

  describe "friend_circles" do
    alias TudoChat.FriendCircles.FriendCircle

    @valid_attrs %{request_message: "some request_message", user_from_id: 42, user_to_id: 42}
    @update_attrs %{
      request_message: "some updated request_message",
      user_from_id: 43,
      user_to_id: 43
    }
    @invalid_attrs %{request_message: nil, user_from_id: nil, user_to_id: nil}

    def friend_circle_fixture(attrs \\ %{}) do
      {:ok, friend_circle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> FriendCircles.create_friend_circle()

      friend_circle
    end

    test "list_friend_circles/0 returns all friend_circles" do
      friend_circle = friend_circle_fixture()
      assert FriendCircles.list_friend_circles() == [friend_circle]
    end

    test "get_friend_circle!/1 returns the friend_circle with given id" do
      friend_circle = friend_circle_fixture()
      assert FriendCircles.get_friend_circle!(friend_circle.id) == friend_circle
    end

    test "create_friend_circle/1 with valid data creates a friend_circle" do
      assert {:ok, %FriendCircle{} = friend_circle} =
               FriendCircles.create_friend_circle(@valid_attrs)

      assert friend_circle.request_message == "some request_message"
      assert friend_circle.user_from_id == 42
      assert friend_circle.user_to_id == 42
    end

    test "create_friend_circle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FriendCircles.create_friend_circle(@invalid_attrs)
    end

    test "update_friend_circle/2 with valid data updates the friend_circle" do
      friend_circle = friend_circle_fixture()

      assert {:ok, %FriendCircle{} = friend_circle} =
               FriendCircles.update_friend_circle(friend_circle, @update_attrs)

      assert friend_circle.request_message == "some updated request_message"
      assert friend_circle.user_from_id == 43
      assert friend_circle.user_to_id == 43
    end

    test "update_friend_circle/2 with invalid data returns error changeset" do
      friend_circle = friend_circle_fixture()

      assert {:error, %Ecto.Changeset{}} =
               FriendCircles.update_friend_circle(friend_circle, @invalid_attrs)

      assert friend_circle == FriendCircles.get_friend_circle!(friend_circle.id)
    end

    test "delete_friend_circle/1 deletes the friend_circle" do
      friend_circle = friend_circle_fixture()
      assert {:ok, %FriendCircle{}} = FriendCircles.delete_friend_circle(friend_circle)

      assert_raise Ecto.NoResultsError, fn ->
        FriendCircles.get_friend_circle!(friend_circle.id)
      end
    end

    test "change_friend_circle/1 returns a friend_circle changeset" do
      friend_circle = friend_circle_fixture()
      assert %Ecto.Changeset{} = FriendCircles.change_friend_circle(friend_circle)
    end
  end
end
