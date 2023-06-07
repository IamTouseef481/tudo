defmodule Core.TaxesTest do
  use Core.DataCase

  alias Core.Taxes

  describe "taxes" do
    alias Core.Schemas.Tax

    @valid_attrs %{amount: 120.5, description: "some description", title: "some title"}
    @update_attrs %{
      amount: 456.7,
      description: "some updated description",
      title: "some updated title"
    }
    @invalid_attrs %{amount: nil, description: nil, title: nil}

    def tax_fixture(attrs \\ %{}) do
      {:ok, tax} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Taxes.create_tax()

      tax
    end

    test "list_taxes/0 returns all taxes" do
      tax = tax_fixture()
      assert Taxes.list_taxes() == [tax]
    end

    test "get_tax!/1 returns the tax with given id" do
      tax = tax_fixture()
      assert Taxes.get_tax!(tax.id) == tax
    end

    test "create_tax/1 with valid data creates a tax" do
      assert {:ok, %Tax{} = tax} = Taxes.create_tax(@valid_attrs)
      assert tax.amount == 120.5
      assert tax.description == "some description"
      assert tax.title == "some title"
    end

    test "create_tax/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Taxes.create_tax(@invalid_attrs)
    end

    test "update_tax/2 with valid data updates the tax" do
      tax = tax_fixture()
      assert {:ok, %Tax{} = tax} = Taxes.update_tax(tax, @update_attrs)
      assert tax.amount == 456.7
      assert tax.description == "some updated description"
      assert tax.title == "some updated title"
    end

    test "update_tax/2 with invalid data returns error changeset" do
      tax = tax_fixture()
      assert {:error, %Ecto.Changeset{}} = Taxes.update_tax(tax, @invalid_attrs)
      assert tax == Taxes.get_tax!(tax.id)
    end

    test "delete_tax/1 deletes the tax" do
      tax = tax_fixture()
      assert {:ok, %Tax{}} = Taxes.delete_tax(tax)
      assert_raise Ecto.NoResultsError, fn -> Taxes.get_tax!(tax.id) end
    end

    test "change_tax/1 returns a tax changeset" do
      tax = tax_fixture()
      assert %Ecto.Changeset{} = Taxes.change_tax(tax)
    end
  end
end
