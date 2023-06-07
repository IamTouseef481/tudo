defmodule TudoChat.GroupsTest do
  use TudoChat.DataCase

  alias TudoChat.Groups

  describe "groups" do
    alias TudoChat.Groups.Group

    @valid_attrs %{
      add_members: true,
      allow_pvt_message: true,
      editable: true,
      expires_by_date: "2010-04-17T14:00:00Z",
      forward: true,
      group_type: "some group_type",
      is_active: true,
      name: "some name",
      profile_pic: "some profile_pic",
      reference_id: 42,
      service_request_id: 42
    }
    @update_attrs %{
      add_members: false,
      allow_pvt_message: false,
      editable: false,
      expires_by_date: "2011-05-18T15:01:01Z",
      forward: false,
      group_type: "some updated group_type",
      is_active: false,
      name: "some updated name",
      profile_pic: "some updated profile_pic",
      reference_id: 43,
      service_request_id: 43
    }
    @invalid_attrs %{
      add_members: nil,
      allow_pvt_message: nil,
      editable: nil,
      expires_by_date: nil,
      forward: nil,
      group_type: nil,
      is_active: nil,
      name: nil,
      profile_pic: nil,
      reference_id: nil,
      service_request_id: nil
    }

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_group()

      group
    end

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Groups.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Groups.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Groups.create_group(@valid_attrs)
      assert group.add_members == true
      assert group.allow_pvt_message == true
      assert group.editable == true
      assert group.expires_by_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert group.forward == true
      assert group.group_type == "some group_type"
      assert group.is_active == true
      assert group.name == "some name"
      assert group.profile_pic == "some profile_pic"
      assert group.reference_id == 42
      assert group.service_request_id == 42
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, %Group{} = group} = Groups.update_group(group, @update_attrs)
      assert group.add_members == false
      assert group.allow_pvt_message == false
      assert group.editable == false
      assert group.expires_by_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert group.forward == false
      assert group.group_type == "some updated group_type"
      assert group.is_active == false
      assert group.name == "some updated name"
      assert group.profile_pic == "some updated profile_pic"
      assert group.reference_id == 43
      assert group.service_request_id == 43
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end

  describe "group_types" do
    alias alias TudoChat.Groups.GroupType

    @valid_attrs %{desc: "some desc", name: "some name", slug: "some slug"}
    @update_attrs %{
      desc: "some updated desc",
      name: "some updated name",
      slug: "some updated slug"
    }
    @invalid_attrs %{desc: nil, name: nil, slug: nil}

    def group_type_fixture(attrs \\ %{}) do
      {:ok, group_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_group_type()

      group_type
    end

    test "list_group_types/0 returns all group_types" do
      group_type = group_type_fixture()
      assert Groups.list_group_types() == [group_type]
    end

    test "get_group_type!/1 returns the group_type with given id" do
      group_type = group_type_fixture()
      assert Groups.get_group_type!(group_type.id) == group_type
    end

    test "create_group_type/1 with valid data creates a group_type" do
      assert {:ok, %Group_type{} = group_type} = Groups.create_group_type(@valid_attrs)
      assert group_type.desc == "some desc"
      assert group_type.name == "some name"
      assert group_type.slug == "some slug"
    end

    test "create_group_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_type(@invalid_attrs)
    end

    test "update_group_type/2 with valid data updates the group_type" do
      group_type = group_type_fixture()

      assert {:ok, %Group_type{} = group_type} =
               Groups.update_group_type(group_type, @update_attrs)

      assert group_type.desc == "some updated desc"
      assert group_type.name == "some updated name"
      assert group_type.slug == "some updated slug"
    end

    test "update_group_type/2 with invalid data returns error changeset" do
      group_type = group_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group_type(group_type, @invalid_attrs)
      assert group_type == Groups.get_group_type!(group_type.id)
    end

    test "delete_group_type/1 deletes the group_type" do
      group_type = group_type_fixture()
      assert {:ok, %Group_type{}} = Groups.delete_group_type(group_type)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group_type!(group_type.id) end
    end

    test "change_group_type/1 returns a group_type changeset" do
      group_type = group_type_fixture()
      assert %Ecto.Changeset{} = Groups.change_group_type(group_type)
    end
  end

  describe "group_members" do
    alias TudoChat.Groups.GroupMember

    @valid_attrs %{is_active: true}
    @update_attrs %{is_active: false}
    @invalid_attrs %{is_active: nil}

    def group_member_fixture(attrs \\ %{}) do
      {:ok, group_member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_group_member()

      group_member
    end

    test "list_group_members/0 returns all group_members" do
      group_member = group_member_fixture()
      assert Groups.list_group_members() == [group_member]
    end

    test "get_group_member!/1 returns the group_member with given id" do
      group_member = group_member_fixture()
      assert Groups.get_group_member!(group_member.id) == group_member
    end

    test "create_group_member/1 with valid data creates a group_member" do
      assert {:ok, %Group_member{} = group_member} = Groups.create_group_member(@valid_attrs)
      assert group_member.is_active == true
    end

    test "create_group_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_member(@invalid_attrs)
    end

    test "update_group_member/2 with valid data updates the group_member" do
      group_member = group_member_fixture()

      assert {:ok, %Group_member{} = group_member} =
               Groups.update_group_member(group_member, @update_attrs)

      assert group_member.is_active == false
    end

    test "update_group_member/2 with invalid data returns error changeset" do
      group_member = group_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Groups.update_group_member(group_member, @invalid_attrs)

      assert group_member == Groups.get_group_member!(group_member.id)
    end

    test "delete_group_member/1 deletes the group_member" do
      group_member = group_member_fixture()
      assert {:ok, %Group_member{}} = Groups.delete_group_member(group_member)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group_member!(group_member.id) end
    end

    test "change_group_member/1 returns a group_member changeset" do
      group_member = group_member_fixture()
      assert %Ecto.Changeset{} = Groups.change_group_member(group_member)
    end
  end

  describe "group_statuses" do
    alias TudoChat.Groups.GroupStatus

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def group_status_fixture(attrs \\ %{}) do
      {:ok, group_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_group_status()

      group_status
    end

    test "list_group_statuses/0 returns all group_statuses" do
      group_status = group_status_fixture()
      assert Groups.list_group_statuses() == [group_status]
    end

    test "get_group_status!/1 returns the group_status with given id" do
      group_status = group_status_fixture()
      assert Groups.get_group_status!(group_status.id) == group_status
    end

    test "create_group_status/1 with valid data creates a group_status" do
      assert {:ok, %GroupStatus{} = group_status} = Groups.create_group_status(@valid_attrs)
      assert group_status.description == "some description"
      assert group_status.id == "some id"
    end

    test "create_group_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_status(@invalid_attrs)
    end

    test "update_group_status/2 with valid data updates the group_status" do
      group_status = group_status_fixture()

      assert {:ok, %GroupStatus{} = group_status} =
               Groups.update_group_status(group_status, @update_attrs)

      assert group_status.description == "some updated description"
      assert group_status.id == "some updated id"
    end

    test "update_group_status/2 with invalid data returns error changeset" do
      group_status = group_status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Groups.update_group_status(group_status, @invalid_attrs)

      assert group_status == Groups.get_group_status!(group_status.id)
    end

    test "delete_group_status/1 deletes the group_status" do
      group_status = group_status_fixture()
      assert {:ok, %GroupStatus{}} = Groups.delete_group_status(group_status)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group_status!(group_status.id) end
    end

    test "change_group_status/1 returns a group_status changeset" do
      group_status = group_status_fixture()
      assert %Ecto.Changeset{} = Groups.change_group_status(group_status)
    end
  end

  describe "group_member_roles" do
    alias TudoChat.Groups.GroupMemberRole

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def group_member_role_fixture(attrs \\ %{}) do
      {:ok, group_member_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Groups.create_group_member_role()

      group_member_role
    end

    test "list_group_member_roles/0 returns all group_member_roles" do
      group_member_role = group_member_role_fixture()
      assert Groups.list_group_member_roles() == [group_member_role]
    end

    test "get_group_member_role!/1 returns the group_member_role with given id" do
      group_member_role = group_member_role_fixture()
      assert Groups.get_group_member_role!(group_member_role.id) == group_member_role
    end

    test "create_group_member_role/1 with valid data creates a group_member_role" do
      assert {:ok, %GroupMemberRole{} = group_member_role} =
               Groups.create_group_member_role(@valid_attrs)

      assert group_member_role.description == "some description"
      assert group_member_role.id == "some id"
    end

    test "create_group_member_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group_member_role(@invalid_attrs)
    end

    test "update_group_member_role/2 with valid data updates the group_member_role" do
      group_member_role = group_member_role_fixture()

      assert {:ok, %GroupMemberRole{} = group_member_role} =
               Groups.update_group_member_role(group_member_role, @update_attrs)

      assert group_member_role.description == "some updated description"
      assert group_member_role.id == "some updated id"
    end

    test "update_group_member_role/2 with invalid data returns error changeset" do
      group_member_role = group_member_role_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Groups.update_group_member_role(group_member_role, @invalid_attrs)

      assert group_member_role == Groups.get_group_member_role!(group_member_role.id)
    end

    test "delete_group_member_role/1 deletes the group_member_role" do
      group_member_role = group_member_role_fixture()
      assert {:ok, %GroupMemberRole{}} = Groups.delete_group_member_role(group_member_role)

      assert_raise Ecto.NoResultsError, fn ->
        Groups.get_group_member_role!(group_member_role.id)
      end
    end

    test "change_group_member_role/1 returns a group_member_role changeset" do
      group_member_role = group_member_role_fixture()
      assert %Ecto.Changeset{} = Groups.change_group_member_role(group_member_role)
    end
  end
end
