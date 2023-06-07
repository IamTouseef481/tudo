defmodule Core.AclTest do
  use Core.DataCase

  alias Core.Acl

  describe "acl_roles" do
    alias Core.Acl.AclRole

    @valid_attrs %{parent: "some parent", role: "some role"}
    @update_attrs %{parent: "some updated parent", role: "some updated role"}
    @invalid_attrs %{parent: nil, role: nil}

    def acl_role_fixture(attrs \\ %{}) do
      {:ok, acl_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Acl.create_acl_role()

      acl_role
    end

    test "list_acl_roles/0 returns all acl_roles" do
      acl_role = acl_role_fixture()
      assert Acl.list_acl_roles() == [acl_role]
    end

    test "get_acl_role!/1 returns the acl_role with given id" do
      acl_role = acl_role_fixture()
      assert Acl.get_acl_role!(acl_role.id) == acl_role
    end

    test "create_acl_role/1 with valid data creates a acl_role" do
      assert {:ok, %AclRole{} = acl_role} = Acl.create_acl_role(@valid_attrs)
      assert acl_role.parent == "some parent"
      assert acl_role.role == "some role"
    end

    test "create_acl_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Acl.create_acl_role(@invalid_attrs)
    end

    test "update_acl_role/2 with valid data updates the acl_role" do
      acl_role = acl_role_fixture()
      assert {:ok, %AclRole{} = acl_role} = Acl.update_acl_role(acl_role, @update_attrs)
      assert acl_role.parent == "some updated parent"
      assert acl_role.role == "some updated role"
    end

    test "update_acl_role/2 with invalid data returns error changeset" do
      acl_role = acl_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Acl.update_acl_role(acl_role, @invalid_attrs)
      assert acl_role == Acl.get_acl_role!(acl_role.id)
    end

    test "delete_acl_role/1 deletes the acl_role" do
      acl_role = acl_role_fixture()
      assert {:ok, %AclRole{}} = Acl.delete_acl_role(acl_role)
      assert_raise Ecto.NoResultsError, fn -> Acl.get_acl_role!(acl_role.id) end
    end

    test "change_acl_role/1 returns a acl_role changeset" do
      acl_role = acl_role_fixture()
      assert %Ecto.Changeset{} = Acl.change_acl_role(acl_role)
    end
  end
end
