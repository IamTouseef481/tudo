defmodule Core.BusinessTest do
  use Core.DataCase

  alias Core.Business

  describe "business_types" do
    alias Core.Schemas.BusinessType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def business_type_fixture(attrs \\ %{}) do
      {:ok, business_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_business_type()

      business_type
    end

    test "list_business_types/0 returns all business_types" do
      business_type = business_type_fixture()
      assert Business.list_business_types() == [business_type]
    end

    test "get_business_type!/1 returns the business_type with given id" do
      business_type = business_type_fixture()
      assert Business.get_business_type!(business_type.id) == business_type
    end

    test "create_business_type/1 with valid data creates a business_type" do
      assert {:ok, %BusinessType{} = business_type} = Business.create_business_type(@valid_attrs)
      assert business_type.name == "some name"
    end

    test "create_business_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_business_type(@invalid_attrs)
    end

    test "update_business_type/2 with valid data updates the business_type" do
      business_type = business_type_fixture()

      assert {:ok, %BusinessType{} = business_type} =
               Business.update_business_type(business_type, @update_attrs)

      assert business_type.name == "some updated name"
    end

    test "update_business_type/2 with invalid data returns error changeset" do
      business_type = business_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Business.update_business_type(business_type, @invalid_attrs)

      assert business_type == Business.get_business_type!(business_type.id)
    end

    test "delete_business_type/1 deletes the business_type" do
      business_type = business_type_fixture()
      assert {:ok, %BusinessType{}} = Business.delete_business_type(business_type)
      assert_raise Ecto.NoResultsError, fn -> Business.get_business_type!(business_type.id) end
    end

    test "change_business_type/1 returns a business_type changeset" do
      business_type = business_type_fixture()
      assert %Ecto.Changeset{} = Business.change_business_type(business_type)
    end
  end

  describe "terms_and_conditions" do
    alias Core.Schemas.TermsAndCondition

    @valid_attrs %{
      end_date: "2010-04-17T14:00:00Z",
      start_date: "2010-04-17T14:00:00Z",
      text: "some text"
    }
    @update_attrs %{
      end_date: "2011-05-18T15:01:01Z",
      start_date: "2011-05-18T15:01:01Z",
      text: "some updated text"
    }
    @invalid_attrs %{end_date: nil, start_date: nil, text: nil}

    def terms_and_condition_fixture(attrs \\ %{}) do
      {:ok, terms_and_condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Business.create_terms_and_condition()

      terms_and_condition
    end

    test "list_terms_and_conditions/0 returns all terms_and_conditions" do
      terms_and_condition = terms_and_condition_fixture()
      assert Business.list_terms_and_conditions() == [terms_and_condition]
    end

    test "get_terms_and_condition!/1 returns the terms_and_condition with given id" do
      terms_and_condition = terms_and_condition_fixture()
      assert Business.get_terms_and_condition!(terms_and_condition.id) == terms_and_condition
    end

    test "create_terms_and_condition/1 with valid data creates a terms_and_condition" do
      assert {:ok, %TermsAndCondition{} = terms_and_condition} =
               Business.create_terms_and_condition(@valid_attrs)

      assert terms_and_condition.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert terms_and_condition.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert terms_and_condition.text == "some text"
    end

    test "create_terms_and_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_terms_and_condition(@invalid_attrs)
    end

    test "update_terms_and_condition/2 with valid data updates the terms_and_condition" do
      terms_and_condition = terms_and_condition_fixture()

      assert {:ok, %TermsAndCondition{} = terms_and_condition} =
               Business.update_terms_and_condition(terms_and_condition, @update_attrs)

      assert terms_and_condition.end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert terms_and_condition.start_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert terms_and_condition.text == "some updated text"
    end

    test "update_terms_and_condition/2 with invalid data returns error changeset" do
      terms_and_condition = terms_and_condition_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Business.update_terms_and_condition(terms_and_condition, @invalid_attrs)

      assert terms_and_condition == Business.get_terms_and_condition!(terms_and_condition.id)
    end

    test "delete_terms_and_condition/1 deletes the terms_and_condition" do
      terms_and_condition = terms_and_condition_fixture()

      assert {:ok, %TermsAndCondition{}} =
               Business.delete_terms_and_condition(terms_and_condition)

      assert_raise Ecto.NoResultsError, fn ->
        Business.get_terms_and_condition!(terms_and_condition.id)
      end
    end

    test "change_terms_and_condition/1 returns a terms_and_condition changeset" do
      terms_and_condition = terms_and_condition_fixture()
      assert %Ecto.Changeset{} = Business.change_terms_and_condition(terms_and_condition)
    end
  end
end
