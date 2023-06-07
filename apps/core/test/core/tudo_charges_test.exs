defmodule Core.TudoChargesTest do
  use Core.DataCase

  alias Core.TudoCharges

  describe "tudo_charges" do
    alias Core.Schemas.TudoCharge

    @valid_attrs %{is_percentage: true, slug: "some slug", title: "some title", value: 120.5}
    @update_attrs %{
      is_percentage: false,
      slug: "some updated slug",
      title: "some updated title",
      value: 456.7
    }
    @invalid_attrs %{is_percentage: nil, slug: nil, title: nil, value: nil}

    def tudo_charge_fixture(attrs \\ %{}) do
      {:ok, tudo_charge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TudoCharges.create_tudo_charge()

      tudo_charge
    end

    test "list_tudo_charges/0 returns all tudo_charges" do
      tudo_charge = tudo_charge_fixture()
      assert TudoCharges.list_tudo_charges() == [tudo_charge]
    end

    test "get_tudo_charge!/1 returns the tudo_charge with given id" do
      tudo_charge = tudo_charge_fixture()
      assert TudoCharges.get_tudo_charge!(tudo_charge.id) == tudo_charge
    end

    test "create_tudo_charge/1 with valid data creates a tudo_charge" do
      assert {:ok, %TudoCharge{} = tudo_charge} = TudoCharges.create_tudo_charge(@valid_attrs)
      assert tudo_charge.is_percentage == true
      assert tudo_charge.slug == "some slug"
      assert tudo_charge.title == "some title"
      assert tudo_charge.value == 120.5
    end

    test "create_tudo_charge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TudoCharges.create_tudo_charge(@invalid_attrs)
    end

    test "update_tudo_charge/2 with valid data updates the tudo_charge" do
      tudo_charge = tudo_charge_fixture()

      assert {:ok, %TudoCharge{} = tudo_charge} =
               TudoCharges.update_tudo_charge(tudo_charge, @update_attrs)

      assert tudo_charge.is_percentage == false
      assert tudo_charge.slug == "some updated slug"
      assert tudo_charge.title == "some updated title"
      assert tudo_charge.value == 456.7
    end

    test "update_tudo_charge/2 with invalid data returns error changeset" do
      tudo_charge = tudo_charge_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TudoCharges.update_tudo_charge(tudo_charge, @invalid_attrs)

      assert tudo_charge == TudoCharges.get_tudo_charge!(tudo_charge.id)
    end

    test "delete_tudo_charge/1 deletes the tudo_charge" do
      tudo_charge = tudo_charge_fixture()
      assert {:ok, %TudoCharge{}} = TudoCharges.delete_tudo_charge(tudo_charge)
      assert_raise Ecto.NoResultsError, fn -> TudoCharges.get_tudo_charge!(tudo_charge.id) end
    end

    test "change_tudo_charge/1 returns a tudo_charge changeset" do
      tudo_charge = tudo_charge_fixture()
      assert %Ecto.Changeset{} = TudoCharges.change_tudo_charge(tudo_charge)
    end
  end
end
