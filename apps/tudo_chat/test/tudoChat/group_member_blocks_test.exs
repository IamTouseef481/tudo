defmodule TudoChat.GroupMemberBlocksTest do
  use TudoChat.DataCase

  alias TudoChat.GroupMemberBlocks

  describe "group_member_blocks" do
    alias TudoChat.GroupMemberBlocks.GroupMemberBlock

    @valid_attrs %{user_from_id: 42, user_to_id: 42}
    @update_attrs %{user_from_id: 43, user_to_id: 43}
    @invalid_attrs %{user_from_id: nil, user_to_id: nil}

    def group_member_block_fixture(attrs \\ %{}) do
      {:ok, group_member_block} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GroupMemberBlocks.create_group_member_block()

      group_member_block
    end

    test "list_group_member_blocks/0 returns all group_member_blocks" do
      group_member_block = group_member_block_fixture()
      assert GroupMemberBlocks.list_group_member_blocks() == [group_member_block]
    end

    test "get_group_member_block!/1 returns the group_member_block with given id" do
      group_member_block = group_member_block_fixture()

      assert GroupMemberBlocks.get_group_member_block!(group_member_block.id) ==
               group_member_block
    end

    test "create_group_member_block/1 with valid data creates a group_member_block" do
      assert {:ok, %GroupMemberBlock{} = group_member_block} =
               GroupMemberBlocks.create_group_member_block(@valid_attrs)

      assert group_member_block.user_from_id == 42
      assert group_member_block.user_to_id == 42
    end

    test "create_group_member_block/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               GroupMemberBlocks.create_group_member_block(@invalid_attrs)
    end

    test "update_group_member_block/2 with valid data updates the group_member_block" do
      group_member_block = group_member_block_fixture()

      assert {:ok, %GroupMemberBlock{} = group_member_block} =
               GroupMemberBlocks.update_group_member_block(group_member_block, @update_attrs)

      assert group_member_block.user_from_id == 43
      assert group_member_block.user_to_id == 43
    end

    test "update_group_member_block/2 with invalid data returns error changeset" do
      group_member_block = group_member_block_fixture()

      assert {:error, %Ecto.Changeset{}} =
               GroupMemberBlocks.update_group_member_block(group_member_block, @invalid_attrs)

      assert group_member_block ==
               GroupMemberBlocks.get_group_member_block!(group_member_block.id)
    end

    test "delete_group_member_block/1 deletes the group_member_block" do
      group_member_block = group_member_block_fixture()

      assert {:ok, %GroupMemberBlock{}} =
               GroupMemberBlocks.delete_group_member_block(group_member_block)

      assert_raise Ecto.NoResultsError, fn ->
        GroupMemberBlocks.get_group_member_block!(group_member_block.id)
      end
    end

    test "change_group_member_block/1 returns a group_member_block changeset" do
      group_member_block = group_member_block_fixture()
      assert %Ecto.Changeset{} = GroupMemberBlocks.change_group_member_block(group_member_block)
    end
  end
end
