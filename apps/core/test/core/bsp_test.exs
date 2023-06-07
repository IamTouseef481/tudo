defmodule Core.BSPTest do
  use Core.DataCase

  alias Core.BSP

  describe "business_types" do
    alias Core.Schemas.BusinessType

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def business_type_fixture(attrs \\ %{}) do
      {:ok, business_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BSP.create_business_type()

      business_type
    end

    test "list_business_types/0 returns all business_types" do
      business_type = business_type_fixture()
      assert BSP.list_business_types() == [business_type]
    end

    test "get_business_type!/1 returns the business_type with given id" do
      business_type = business_type_fixture()
      assert BSP.get_business_type!(business_type.id) == business_type
    end

    test "create_business_type/1 with valid data creates a business_type" do
      assert {:ok, %BusinessType{} = business_type} = BSP.create_business_type(@valid_attrs)
      assert business_type.name == "some name"
    end

    test "create_business_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BSP.create_business_type(@invalid_attrs)
    end

    test "update_business_type/2 with valid data updates the business_type" do
      business_type = business_type_fixture()

      assert {:ok, %BusinessType{} = business_type} =
               BSP.update_business_type(business_type, @update_attrs)

      assert business_type.name == "some updated name"
    end

    test "update_business_type/2 with invalid data returns error changeset" do
      business_type = business_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BSP.update_business_type(business_type, @invalid_attrs)
      assert business_type == BSP.get_business_type!(business_type.id)
    end

    test "delete_business_type/1 deletes the business_type" do
      business_type = business_type_fixture()
      assert {:ok, %BusinessType{}} = BSP.delete_business_type(business_type)
      assert_raise Ecto.NoResultsError, fn -> BSP.get_business_type!(business_type.id) end
    end

    test "change_business_type/1 returns a business_type changeset" do
      business_type = business_type_fixture()
      assert %Ecto.Changeset{} = BSP.change_business_type(business_type)
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
        |> BSP.create_terms_and_condition()

      terms_and_condition
    end

    test "list_terms_and_conditions/0 returns all terms_and_conditions" do
      terms_and_condition = terms_and_condition_fixture()
      assert BSP.list_terms_and_conditions() == [terms_and_condition]
    end

    test "get_terms_and_condition!/1 returns the terms_and_condition with given id" do
      terms_and_condition = terms_and_condition_fixture()
      assert BSP.get_terms_and_condition!(terms_and_condition.id) == terms_and_condition
    end

    test "create_terms_and_condition/1 with valid data creates a terms_and_condition" do
      assert {:ok, %TermsAndCondition{} = terms_and_condition} =
               BSP.create_terms_and_condition(@valid_attrs)

      assert terms_and_condition.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert terms_and_condition.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert terms_and_condition.text == "some text"
    end

    test "create_terms_and_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BSP.create_terms_and_condition(@invalid_attrs)
    end

    test "update_terms_and_condition/2 with valid data updates the terms_and_condition" do
      terms_and_condition = terms_and_condition_fixture()

      assert {:ok, %TermsAndCondition{} = terms_and_condition} =
               BSP.update_terms_and_condition(terms_and_condition, @update_attrs)

      assert terms_and_condition.end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert terms_and_condition.start_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert terms_and_condition.text == "some updated text"
    end

    test "update_terms_and_condition/2 with invalid data returns error changeset" do
      terms_and_condition = terms_and_condition_fixture()

      assert {:error, %Ecto.Changeset{}} =
               BSP.update_terms_and_condition(terms_and_condition, @invalid_attrs)

      assert terms_and_condition == BSP.get_terms_and_condition!(terms_and_condition.id)
    end

    test "delete_terms_and_condition/1 deletes the terms_and_condition" do
      terms_and_condition = terms_and_condition_fixture()
      assert {:ok, %TermsAndCondition{}} = BSP.delete_terms_and_condition(terms_and_condition)

      assert_raise Ecto.NoResultsError, fn ->
        BSP.get_terms_and_condition!(terms_and_condition.id)
      end
    end

    test "change_terms_and_condition/1 returns a terms_and_condition changeset" do
      terms_and_condition = terms_and_condition_fixture()
      assert %Ecto.Changeset{} = BSP.change_terms_and_condition(terms_and_condition)
    end
  end

  describe "businesses" do
    alias Core.Schemas.Business

    @valid_attrs %{
      agree_to_pay_for_verification: true,
      is_active: true,
      is_verified: true,
      legal_name: "some legal_name",
      no_of_employees: 42,
      no_of_ratings: 42,
      profile_pictures: [],
      settings: %{},
      user_rating: "120.5"
    }
    @update_attrs %{
      agree_to_pay_for_verification: false,
      is_active: false,
      is_verified: false,
      legal_name: "some updated legal_name",
      no_of_employees: 43,
      no_of_ratings: 43,
      profile_pictures: [],
      settings: %{},
      user_rating: "456.7"
    }
    @invalid_attrs %{
      agree_to_pay_for_verification: nil,
      is_active: nil,
      is_verified: nil,
      legal_name: nil,
      no_of_employees: nil,
      no_of_ratings: nil,
      profile_pictures: nil,
      settings: nil,
      user_rating: nil
    }

    def business_fixture(attrs \\ %{}) do
      {:ok, business} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BSP.create_business()

      business
    end

    test "list_businesses/0 returns all businesses" do
      business = business_fixture()
      assert BSP.list_businesses() == [business]
    end

    test "get_business!/1 returns the business with given id" do
      business = business_fixture()
      assert BSP.get_business!(business.id) == business
    end

    test "create_business/1 with valid data creates a business" do
      assert {:ok, %Business{} = business} = BSP.create_business(@valid_attrs)
      assert business.agree_to_pay_for_verification == true
      assert business.is_active == true
      assert business.is_verified == true
      assert business.legal_name == "some legal_name"
      assert business.no_of_employees == 42
      assert business.no_of_ratings == 42
      assert business.profile_pictures == []
      assert business.settings == %{}
      assert business.user_rating == Decimal.new("120.5")
    end

    test "create_business/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BSP.create_business(@invalid_attrs)
    end

    test "update_business/2 with valid data updates the business" do
      business = business_fixture()
      assert {:ok, %Business{} = business} = BSP.update_business(business, @update_attrs)
      assert business.agree_to_pay_for_verification == false
      assert business.is_active == false
      assert business.is_verified == false
      assert business.legal_name == "some updated legal_name"
      assert business.no_of_employees == 43
      assert business.no_of_ratings == 43
      assert business.profile_pictures == []
      assert business.settings == %{}
      assert business.user_rating == Decimal.new("456.7")
    end

    test "update_business/2 with invalid data returns error changeset" do
      business = business_fixture()
      assert {:error, %Ecto.Changeset{}} = BSP.update_business(business, @invalid_attrs)
      assert business == BSP.get_business!(business.id)
    end

    test "delete_business/1 deletes the business" do
      business = business_fixture()
      assert {:ok, %Business{}} = BSP.delete_business(business)
      assert_raise Ecto.NoResultsError, fn -> BSP.get_business!(business.id) end
    end

    test "change_business/1 returns a business changeset" do
      business = business_fixture()
      assert %Ecto.Changeset{} = BSP.change_business(business)
    end
  end

  describe "branches" do
    alias Core.Schemas.Branch

    @valid_attrs %{
      address_lines: %{},
      est_year: 42,
      is_active: true,
      is_head_office: true,
      legal_name: "some legal_name",
      licence_expiry_date: "2010-04-17T14:00:00Z",
      licence_no: "some licence_no",
      licence_photos: %{},
      location: "some location",
      no_of_ratings: 42,
      phone_number: "some phone_number",
      profile_pictures: [],
      user_rating: "120.5"
    }
    @update_attrs %{
      address_lines: %{},
      est_year: 43,
      is_active: false,
      is_head_office: false,
      legal_name: "some updated legal_name",
      licence_expiry_date: "2011-05-18T15:01:01Z",
      licence_no: "some updated licence_no",
      licence_photos: %{},
      location: "some updated location",
      no_of_ratings: 43,
      phone_number: "some updated phone_number",
      profile_pictures: [],
      user_rating: "456.7"
    }
    @invalid_attrs %{
      address_lines: nil,
      est_year: nil,
      is_active: nil,
      is_head_office: nil,
      legal_name: nil,
      licence_expiry_date: nil,
      licence_no: nil,
      licence_photos: nil,
      location: nil,
      no_of_ratings: nil,
      phone_number: nil,
      profile_pictures: nil,
      user_rating: nil
    }

    def branches_fixture(attrs \\ %{}) do
      {:ok, branch} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BSP.create_branch()

      branch
    end

    test "list_branches/0 returns all branches" do
      branches = branches_fixture()
      assert BSP.list_branches() == [branches]
    end

    test "get_branches!/1 returns the branches with given id" do
      branch = branches_fixture()
      assert BSP.get_branch!(branch.id) == branch
    end

    test "create_branch/1 with valid data creates a branch" do
      assert {:ok, %Branch{} = branches} = BSP.create_branch(@valid_attrs)
      assert branch.address_lines == %{}
      assert branch.est_year == 42
      assert branch.is_active == true
      assert branch.is_head_office == true
      assert branch.legal_name == "some legal_name"

      assert branch.licence_expiry_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert branch.licence_no == "some licence_no"
      assert branch.licence_photos == %{}
      assert branch.location == "some location"
      assert branch.no_of_ratings == 42
      assert branch.phone_number == "some phone_number"
      assert branch.profile_pictures == []
      assert branch.user_rating == Decimal.new("120.5")
    end

    test "create_branch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BSP.create_branch(@invalid_attrs)
    end

    test "update_branch/2 with valid data updates the branch" do
      branch = branches_fixture()
      assert {:ok, %Branch{} = branches} = BSP.update_branch(branch, @update_attrs)
      assert branch.address_lines == %{}
      assert branch.est_year == 43
      assert branch.is_active == false
      assert branch.is_head_office == false
      assert branch.legal_name == "some updated legal_name"

      assert branch.licence_expiry_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert branch.licence_no == "some updated licence_no"
      assert branch.licence_photos == %{}
      assert branch.location == "some updated location"
      assert branch.no_of_ratings == 43
      assert branch.phone_number == "some updated phone_number"
      assert branch.profile_pictures == []
      assert branch.user_rating == Decimal.new("456.7")
    end

    test "update_branch/2 with invalid data returns error changeset" do
      branch = branches_fixture()
      assert {:error, %Ecto.Changeset{}} = BSP.update_branch(branch, @invalid_attrs)
      assert branch == BSP.get_branch!(branch.id)
    end

    test "delete_branches/1 deletes the branches" do
      branch = branches_fixture()
      assert {:ok, %Branch{}} = BSP.delete_branch(branch)
      assert_raise Ecto.NoResultsError, fn -> BSP.get_branch!(branch.id) end
    end

    test "change_branches/1 returns a branches changeset" do
      branches = branches_fixture()
      assert %Ecto.Changeset{} = BSP.change_branches(branches)
    end
  end

  describe "dropdowns" do
    alias Core.Schemas.Dropdown

    @valid_attrs %{name: "some name", slug: "some slug", type: "some type"}
    @update_attrs %{
      name: "some updated name",
      slug: "some updated slug",
      type: "some updated type"
    }
    @invalid_attrs %{name: nil, slug: nil, type: nil}

    def dropdown_fixture(attrs \\ %{}) do
      {:ok, dropdown} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BSP.create_dropdown()

      dropdown
    end

    test "list_dropdowns/0 returns all dropdowns" do
      dropdown = dropdown_fixture()
      assert BSP.list_dropdowns() == [dropdown]
    end

    test "get_dropdown!/1 returns the dropdown with given id" do
      dropdown = dropdown_fixture()
      assert BSP.get_dropdown!(dropdown.id) == dropdown
    end

    test "create_dropdown/1 with valid data creates a dropdown" do
      assert {:ok, %Dropdown{} = dropdown} = BSP.create_dropdown(@valid_attrs)
      assert dropdown.name == "some name"
      assert dropdown.slug == "some slug"
      assert dropdown.type == "some type"
    end

    test "create_dropdown/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BSP.create_dropdown(@invalid_attrs)
    end

    test "update_dropdown/2 with valid data updates the dropdown" do
      dropdown = dropdown_fixture()
      assert {:ok, %Dropdown{} = dropdown} = BSP.update_dropdown(dropdown, @update_attrs)
      assert dropdown.name == "some updated name"
      assert dropdown.slug == "some updated slug"
      assert dropdown.type == "some updated type"
    end

    test "update_dropdown/2 with invalid data returns error changeset" do
      dropdown = dropdown_fixture()
      assert {:error, %Ecto.Changeset{}} = BSP.update_dropdown(dropdown, @invalid_attrs)
      assert dropdown == BSP.get_dropdown!(dropdown.id)
    end

    test "delete_dropdown/1 deletes the dropdown" do
      dropdown = dropdown_fixture()
      assert {:ok, %Dropdown{}} = BSP.delete_dropdown(dropdown)
      assert_raise Ecto.NoResultsError, fn -> BSP.get_dropdown!(dropdown.id) end
    end

    test "change_dropdown/1 returns a dropdown changeset" do
      dropdown = dropdown_fixture()
      assert %Ecto.Changeset{} = BSP.change_dropdown(dropdown)
    end
  end
end
