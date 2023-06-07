defmodule TudoChat.MessagesTest do
  use TudoChat.DataCase

  alias TudoChat.Messages

  describe "com_group_messages" do
    alias TudoChat.Messages.ComGroupMessage

    @valid_attrs %{
      content_type: "some content_type",
      is_active: true,
      is_personal: true,
      message: "some message"
    }
    @update_attrs %{
      content_type: "some updated content_type",
      is_active: false,
      is_personal: false,
      message: "some updated message"
    }
    @invalid_attrs %{content_type: nil, is_active: nil, is_personal: nil, message: nil}

    def com_group_message_fixture(attrs \\ %{}) do
      {:ok, com_group_message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messages.create_com_group_message()

      com_group_message
    end

    test "list_com_group_messages/0 returns all com_group_messages" do
      com_group_message = com_group_message_fixture()
      assert Messages.list_com_group_messages() == [com_group_message]
    end

    test "get_com_group_message!/1 returns the com_group_message with given id" do
      com_group_message = com_group_message_fixture()
      assert Messages.get_com_group_message!(com_group_message.id) == com_group_message
    end

    test "create_com_group_message/1 with valid data creates a com_group_message" do
      assert {:ok, %ComGroupMessage{} = com_group_message} =
               Messages.create_com_group_message(@valid_attrs)

      assert com_group_message.content_type == "some content_type"
      assert com_group_message.is_active == true
      assert com_group_message.is_personal == true
      assert com_group_message.message == "some message"
    end

    test "create_com_group_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_com_group_message(@invalid_attrs)
    end

    test "update_com_group_message/2 with valid data updates the com_group_message" do
      com_group_message = com_group_message_fixture()

      assert {:ok, %ComGroupMessage{} = com_group_message} =
               Messages.update_com_group_message(com_group_message, @update_attrs)

      assert com_group_message.content_type == "some updated content_type"
      assert com_group_message.is_active == false
      assert com_group_message.is_personal == false
      assert com_group_message.message == "some updated message"
    end

    test "update_com_group_message/2 with invalid data returns error changeset" do
      com_group_message = com_group_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Messages.update_com_group_message(com_group_message, @invalid_attrs)

      assert com_group_message == Messages.get_com_group_message!(com_group_message.id)
    end

    test "delete_com_group_message/1 deletes the com_group_message" do
      com_group_message = com_group_message_fixture()
      assert {:ok, %ComGroupMessage{}} = Messages.delete_com_group_message(com_group_message)

      assert_raise Ecto.NoResultsError, fn ->
        Messages.get_com_group_message!(com_group_message.id)
      end
    end

    test "change_com_group_message/1 returns a com_group_message changeset" do
      com_group_message = com_group_message_fixture()
      assert %Ecto.Changeset{} = Messages.change_com_group_message(com_group_message)
    end
  end

  describe "messages_meta" do
    alias TudoChat.Messages.MessageMeta

    @valid_attrs %{deleted: true, favourite: true, liked: true, read: true, user_id: 42}
    @update_attrs %{deleted: false, favourite: false, liked: false, read: false, user_id: 43}
    @invalid_attrs %{deleted: nil, favourite: nil, liked: nil, read: nil, user_id: nil}

    def message_meta_fixture(attrs \\ %{}) do
      {:ok, message_meta} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Messages.create_message_meta()

      message_meta
    end

    test "list_messages_meta/0 returns all messages_meta" do
      message_meta = message_meta_fixture()
      assert Messages.list_messages_meta() == [message_meta]
    end

    test "get_message_meta!/1 returns the message_meta with given id" do
      message_meta = message_meta_fixture()
      assert Messages.get_message_meta!(message_meta.id) == message_meta
    end

    test "create_message_meta/1 with valid data creates a message_meta" do
      assert {:ok, %MessageMeta{} = message_meta} = Messages.create_message_meta(@valid_attrs)
      assert message_meta.deleted == true
      assert message_meta.favourite == true
      assert message_meta.liked == true
      assert message_meta.read == true
      assert message_meta.user_id == 42
    end

    test "create_message_meta/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message_meta(@invalid_attrs)
    end

    test "update_message_meta/2 with valid data updates the message_meta" do
      message_meta = message_meta_fixture()

      assert {:ok, %MessageMeta{} = message_meta} =
               Messages.update_message_meta(message_meta, @update_attrs)

      assert message_meta.deleted == false
      assert message_meta.favourite == false
      assert message_meta.liked == false
      assert message_meta.read == false
      assert message_meta.user_id == 43
    end

    test "update_message_meta/2 with invalid data returns error changeset" do
      message_meta = message_meta_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Messages.update_message_meta(message_meta, @invalid_attrs)

      assert message_meta == Messages.get_message_meta!(message_meta.id)
    end

    test "delete_message_meta/1 deletes the message_meta" do
      message_meta = message_meta_fixture()
      assert {:ok, %MessageMeta{}} = Messages.delete_message_meta(message_meta)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message_meta!(message_meta.id) end
    end

    test "change_message_meta/1 returns a message_meta changeset" do
      message_meta = message_meta_fixture()
      assert %Ecto.Changeset{} = Messages.change_message_meta(message_meta)
    end
  end
end
