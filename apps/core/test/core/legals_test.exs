defmodule Core.LegalsTest do
  use Core.DataCase

  alias Core.Legals

  describe "licence_issuing_authorities" do
    alias Core.Schemas.LicenceIssuingAuthorities

    @valid_attrs %{is_active: true, name: "some name"}
    @update_attrs %{is_active: false, name: "some updated name"}
    @invalid_attrs %{is_active: nil, name: nil}

    def licence_issuing_authorities_fixture(attrs \\ %{}) do
      {:ok, licence_issuing_authorities} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Legals.create_licence_issuing_authorities()

      licence_issuing_authorities
    end

    test "list_licence_issuing_authorities/0 returns all licence_issuing_authorities" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()
      assert Legals.list_licence_issuing_authorities() == [licence_issuing_authorities]
    end

    test "get_licence_issuing_authorities!/1 returns the licence_issuing_authorities with given id" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()

      assert Legals.get_licence_issuing_authorities!(licence_issuing_authorities.id) ==
               licence_issuing_authorities
    end

    test "create_licence_issuing_authorities/1 with valid data creates a licence_issuing_authorities" do
      assert {:ok, %LicenceIssuingAuthorities{} = licence_issuing_authorities} =
               Legals.create_licence_issuing_authorities(@valid_attrs)

      assert licence_issuing_authorities.is_active == true
      assert licence_issuing_authorities.name == "some name"
    end

    test "create_licence_issuing_authorities/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Legals.create_licence_issuing_authorities(@invalid_attrs)
    end

    test "update_licence_issuing_authorities/2 with valid data updates the licence_issuing_authorities" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()

      assert {:ok, %LicenceIssuingAuthorities{} = licence_issuing_authorities} =
               Legals.update_licence_issuing_authorities(
                 licence_issuing_authorities,
                 @update_attrs
               )

      assert licence_issuing_authorities.is_active == false
      assert licence_issuing_authorities.name == "some updated name"
    end

    test "update_licence_issuing_authorities/2 with invalid data returns error changeset" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Legals.update_licence_issuing_authorities(
                 licence_issuing_authorities,
                 @invalid_attrs
               )

      assert licence_issuing_authorities ==
               Legals.get_licence_issuing_authorities!(licence_issuing_authorities.id)
    end

    test "delete_licence_issuing_authorities/1 deletes the licence_issuing_authorities" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()

      assert {:ok, %LicenceIssuingAuthorities{}} =
               Legals.delete_licence_issuing_authorities(licence_issuing_authorities)

      assert_raise Ecto.NoResultsError, fn ->
        Legals.get_licence_issuing_authorities!(licence_issuing_authorities.id)
      end
    end

    test "change_licence_issuing_authorities/1 returns a licence_issuing_authorities changeset" do
      licence_issuing_authorities = licence_issuing_authorities_fixture()

      assert %Ecto.Changeset{} =
               Legals.change_licence_issuing_authorities(licence_issuing_authorities)
    end
  end

  describe "platform_terms_and_conditions" do
    alias Core.Schemas.PlatformTermAndCondition

    @valid_attrs %{
      country_id: 42,
      end_date: "2010-04-17T14:00:00Z",
      start_date: "2010-04-17T14:00:00Z",
      type: "some type",
      url: "some url"
    }
    @update_attrs %{
      country_id: 43,
      end_date: "2011-05-18T15:01:01Z",
      start_date: "2011-05-18T15:01:01Z",
      type: "some updated type",
      url: "some updated url"
    }
    @invalid_attrs %{country_id: nil, end_date: nil, start_date: nil, type: nil, url: nil}

    def platform_term_and_condition_fixture(attrs \\ %{}) do
      {:ok, platform_term_and_condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Legals.create_platform_term_and_condition()

      platform_term_and_condition
    end

    test "list_platform_terms_and_conditions/0 returns all platform_terms_and_conditions" do
      platform_term_and_condition = platform_term_and_condition_fixture()
      assert Legals.list_platform_terms_and_conditions() == [platform_term_and_condition]
    end

    test "get_platform_term_and_condition!/1 returns the platform_term_and_condition with given id" do
      platform_term_and_condition = platform_term_and_condition_fixture()

      assert Legals.get_platform_term_and_condition!(platform_term_and_condition.id) ==
               platform_term_and_condition
    end

    test "create_platform_term_and_condition/1 with valid data creates a platform_term_and_condition" do
      assert {:ok, %PlatformTermAndCondition{} = platform_term_and_condition} =
               Legals.create_platform_term_and_condition(@valid_attrs)

      assert platform_term_and_condition.country_id == 42

      assert platform_term_and_condition.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert platform_term_and_condition.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert platform_term_and_condition.type == "some type"
      assert platform_term_and_condition.url == "some url"
    end

    test "create_platform_term_and_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Legals.create_platform_term_and_condition(@invalid_attrs)
    end

    test "update_platform_term_and_condition/2 with valid data updates the platform_term_and_condition" do
      platform_term_and_condition = platform_term_and_condition_fixture()

      assert {:ok, %PlatformTermAndCondition{} = platform_term_and_condition} =
               Legals.update_platform_term_and_condition(
                 platform_term_and_condition,
                 @update_attrs
               )

      assert platform_term_and_condition.country_id == 43

      assert platform_term_and_condition.end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert platform_term_and_condition.start_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert platform_term_and_condition.type == "some updated type"
      assert platform_term_and_condition.url == "some updated url"
    end

    test "update_platform_term_and_condition/2 with invalid data returns error changeset" do
      platform_term_and_condition = platform_term_and_condition_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Legals.update_platform_term_and_condition(
                 platform_term_and_condition,
                 @invalid_attrs
               )

      assert platform_term_and_condition ==
               Legals.get_platform_term_and_condition!(platform_term_and_condition.id)
    end

    test "delete_platform_term_and_condition/1 deletes the platform_term_and_condition" do
      platform_term_and_condition = platform_term_and_condition_fixture()

      assert {:ok, %PlatformTermAndCondition{}} =
               Legals.delete_platform_term_and_condition(platform_term_and_condition)

      assert_raise Ecto.NoResultsError, fn ->
        Legals.get_platform_term_and_condition!(platform_term_and_condition.id)
      end
    end

    test "change_platform_term_and_condition/1 returns a platform_term_and_condition changeset" do
      platform_term_and_condition = platform_term_and_condition_fixture()

      assert %Ecto.Changeset{} =
               Legals.change_platform_term_and_condition(platform_term_and_condition)
    end
  end
end
