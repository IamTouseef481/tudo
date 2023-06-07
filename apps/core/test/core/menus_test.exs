defmodule Core.MenusTest do
  use Core.DataCase

  alias Core.Menus

  describe "menus" do
    alias Core.Schemas.Menu

    @valid_attrs %{
      description: "some description",
      doc_order: 42,
      images: %{},
      is_active: true,
      menu_order: 42,
      slug: "some slug"
    }
    @update_attrs %{
      description: "some updated description",
      doc_order: 43,
      images: %{},
      is_active: false,
      menu_order: 43,
      slug: "some updated slug"
    }
    @invalid_attrs %{
      description: nil,
      doc_order: nil,
      images: nil,
      is_active: nil,
      menu_order: nil,
      slug: nil
    }

    def menu_fixture(attrs \\ %{}) do
      {:ok, menu} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Menus.create_menu()

      menu
    end

    test "list_menus/0 returns all menus" do
      menu = menu_fixture()
      assert Menus.list_menus() == [menu]
    end

    test "get_menu!/1 returns the menu with given id" do
      menu = menu_fixture()
      assert Menus.get_menu!(menu.id) == menu
    end

    test "create_menu/1 with valid data creates a menu" do
      assert {:ok, %Menu{} = menu} = Menus.create_menu(@valid_attrs)
      assert menu.description == "some description"
      assert menu.doc_order == 42
      assert menu.images == %{}
      assert menu.is_active == true
      assert menu.menu_order == 42
      assert menu.slug == "some slug"
    end

    test "create_menu/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu(@invalid_attrs)
    end

    test "update_menu/2 with valid data updates the menu" do
      menu = menu_fixture()
      assert {:ok, %Menu{} = menu} = Menus.update_menu(menu, @update_attrs)
      assert menu.description == "some updated description"
      assert menu.doc_order == 43
      assert menu.images == %{}
      assert menu.is_active == false
      assert menu.menu_order == 43
      assert menu.slug == "some updated slug"
    end

    test "update_menu/2 with invalid data returns error changeset" do
      menu = menu_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu(menu, @invalid_attrs)
      assert menu == Menus.get_menu!(menu.id)
    end

    test "delete_menu/1 deletes the menu" do
      menu = menu_fixture()
      assert {:ok, %Menu{}} = Menus.delete_menu(menu)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu!(menu.id) end
    end

    test "change_menu/1 returns a menu changeset" do
      menu = menu_fixture()
      assert %Ecto.Changeset{} = Menus.change_menu(menu)
    end
  end

  describe "menu_roles" do
    alias Core.Schemas.MenuRole

    @valid_attrs %{doc_order: "some doc_order", menu_order: "some menu_order"}
    @update_attrs %{doc_order: "some updated doc_order", menu_order: "some updated menu_order"}
    @invalid_attrs %{doc_order: nil, menu_order: nil}

    def menu_role_fixture(attrs \\ %{}) do
      {:ok, menu_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Menus.create_menu_role()

      menu_role
    end

    test "list_menu_roles/0 returns all menu_roles" do
      menu_role = menu_role_fixture()
      assert Menus.list_menu_roles() == [menu_role]
    end

    test "get_menu_role!/1 returns the menu_role with given id" do
      menu_role = menu_role_fixture()
      assert Menus.get_menu_role!(menu_role.id) == menu_role
    end

    test "create_menu_role/1 with valid data creates a menu_role" do
      assert {:ok, %MenuRole{} = menu_role} = Menus.create_menu_role(@valid_attrs)
      assert menu_role.doc_order == "some doc_order"
      assert menu_role.menu_order == "some menu_order"
    end

    test "create_menu_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu_role(@invalid_attrs)
    end

    test "update_menu_role/2 with valid data updates the menu_role" do
      menu_role = menu_role_fixture()
      assert {:ok, %MenuRole{} = menu_role} = Menus.update_menu_role(menu_role, @update_attrs)
      assert menu_role.doc_order == "some updated doc_order"
      assert menu_role.menu_order == "some updated menu_order"
    end

    test "update_menu_role/2 with invalid data returns error changeset" do
      menu_role = menu_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu_role(menu_role, @invalid_attrs)
      assert menu_role == Menus.get_menu_role!(menu_role.id)
    end

    test "delete_menu_role/1 deletes the menu_role" do
      menu_role = menu_role_fixture()
      assert {:ok, %MenuRole{}} = Menus.delete_menu_role(menu_role)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu_role!(menu_role.id) end
    end

    test "change_menu_role/1 returns a menu_role changeset" do
      menu_role = menu_role_fixture()
      assert %Ecto.Changeset{} = Menus.change_menu_role(menu_role)
    end
  end
end
