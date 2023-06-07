defmodule Core.AccountsTest do
  use Core.DataCase

  alias Core.Accounts

  describe "user_installs" do
    alias Core.Schemas.UserInstalls

    @valid_attrs %{
      device_info: %{},
      device_token: "some device_token",
      fcm_token: "some fcm_token",
      os: "some os"
    }
    @update_attrs %{
      device_info: %{},
      device_token: "some updated device_token",
      fcm_token: "some updated fcm_token",
      os: "some updated os"
    }
    @invalid_attrs %{device_info: nil, device_token: nil, fcm_token: nil, os: nil}

    def user_installs_fixture(attrs \\ %{}) do
      {:ok, user_installs} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_installs()

      user_installs
    end

    test "list_user_installs/0 returns all user_installs" do
      user_installs = user_installs_fixture()
      assert Accounts.list_user_installs() == [user_installs]
    end

    test "get_user_installs!/1 returns the user_installs with given id" do
      user_installs = user_installs_fixture()
      assert Accounts.get_user_installs!(user_installs.id) == user_installs
    end

    test "create_user_installs/1 with valid data creates a user_installs" do
      assert {:ok, %UserInstalls{} = user_installs} = Accounts.create_user_installs(@valid_attrs)
      assert user_installs.device_info == %{}
      assert user_installs.device_token == "some device_token"
      assert user_installs.fcm_token == "some fcm_token"
      assert user_installs.os == "some os"
    end

    test "create_user_installs/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_installs(@invalid_attrs)
    end

    test "update_user_installs/2 with valid data updates the user_installs" do
      user_installs = user_installs_fixture()

      assert {:ok, %UserInstalls{} = user_installs} =
               Accounts.update_user_installs(user_installs, @update_attrs)

      assert user_installs.device_info == %{}
      assert user_installs.device_token == "some updated device_token"
      assert user_installs.fcm_token == "some updated fcm_token"
      assert user_installs.os == "some updated os"
    end

    test "update_user_installs/2 with invalid data returns error changeset" do
      user_installs = user_installs_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_installs(user_installs, @invalid_attrs)

      assert user_installs == Accounts.get_user_installs!(user_installs.id)
    end

    test "delete_user_installs/1 deletes the user_installs" do
      user_installs = user_installs_fixture()
      assert {:ok, %UserInstalls{}} = Accounts.delete_user_installs(user_installs)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_installs!(user_installs.id) end
    end

    test "change_user_installs/1 returns a user_installs changeset" do
      user_installs = user_installs_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_installs(user_installs)
    end
  end

  describe "user_status" do
    alias Core.Schemas.UserStatus

    @valid_attrs %{description: "some description", slug: "some slug", title: "some title"}
    @update_attrs %{
      description: "some updated description",
      slug: "some updated slug",
      title: "some updated title"
    }
    @invalid_attrs %{description: nil, slug: nil, title: nil}

    def user_status_fixture(attrs \\ %{}) do
      {:ok, user_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_status()

      user_status
    end

    test "list_user_status/0 returns all user_status" do
      user_status = user_status_fixture()
      assert Accounts.list_user_status() == [user_status]
    end

    test "get_user_status!/1 returns the user_status with given id" do
      user_status = user_status_fixture()
      assert Accounts.get_user_status!(user_status.id) == user_status
    end

    test "create_user_status/1 with valid data creates a user_status" do
      assert {:ok, %UserStatus{} = user_status} = Accounts.create_user_status(@valid_attrs)
      assert user_status.description == "some description"
      assert user_status.slug == "some slug"
      assert user_status.title == "some title"
    end

    test "create_user_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_status(@invalid_attrs)
    end

    test "update_user_status/2 with valid data updates the user_status" do
      user_status = user_status_fixture()

      assert {:ok, %UserStatus{} = user_status} =
               Accounts.update_user_status(user_status, @update_attrs)

      assert user_status.description == "some updated description"
      assert user_status.slug == "some updated slug"
      assert user_status.title == "some updated title"
    end

    test "update_user_status/2 with invalid data returns error changeset" do
      user_status = user_status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_status(user_status, @invalid_attrs)

      assert user_status == Accounts.get_user_status!(user_status.id)
    end

    test "delete_user_status/1 deletes the user_status" do
      user_status = user_status_fixture()
      assert {:ok, %UserStatus{}} = Accounts.delete_user_status(user_status)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_status!(user_status.id) end
    end

    test "change_user_status/1 returns a user_status changeset" do
      user_status = user_status_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_status(user_status)
    end
  end

  describe "user_addresses" do
    alias Core.Schemas.UserAddress

    @valid_attrs %{address: "some address", geo_location: "some geo_location", slug: "some slug"}
    @update_attrs %{
      address: "some updated address",
      geo_location: "some updated geo_location",
      slug: "some updated slug"
    }
    @invalid_attrs %{address: nil, geo_location: nil, slug: nil}

    def user_address_fixture(attrs \\ %{}) do
      {:ok, user_address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_address()

      user_address
    end

    test "list_user_addresses/0 returns all user_addresses" do
      user_address = user_address_fixture()
      assert Accounts.list_user_addresses() == [user_address]
    end

    test "get_user_address!/1 returns the user_address with given id" do
      user_address = user_address_fixture()
      assert Accounts.get_user_address!(user_address.id) == user_address
    end

    test "create_user_address/1 with valid data creates a user_address" do
      assert {:ok, %UserAddress{} = user_address} = Accounts.create_user_address(@valid_attrs)
      assert user_address.address == "some address"
      assert user_address.geo_location == "some geo_location"
      assert user_address.slug == "some slug"
    end

    test "create_user_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_address(@invalid_attrs)
    end

    test "update_user_address/2 with valid data updates the user_address" do
      user_address = user_address_fixture()

      assert {:ok, %UserAddress{} = user_address} =
               Accounts.update_user_address(user_address, @update_attrs)

      assert user_address.address == "some updated address"
      assert user_address.geo_location == "some updated geo_location"
      assert user_address.slug == "some updated slug"
    end

    test "update_user_address/2 with invalid data returns error changeset" do
      user_address = user_address_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_address(user_address, @invalid_attrs)

      assert user_address == Accounts.get_user_address!(user_address.id)
    end

    test "delete_user_address/1 deletes the user_address" do
      user_address = user_address_fixture()
      assert {:ok, %UserAddress{}} = Accounts.delete_user_address(user_address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_address!(user_address.id) end
    end

    test "change_user_address/1 returns a user_address changeset" do
      user_address = user_address_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_address(user_address)
    end
  end
end
