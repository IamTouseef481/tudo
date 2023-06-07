defmodule Core.PolicyTest do
  use Core.DataCase

  alias Core.Policy

  describe "platform_terms_and_conditions" do
    alias Core.Policy.PlatformTermsAndConditions

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

    def platform_terms_and_conditions_fixture(attrs \\ %{}) do
      {:ok, platform_terms_and_conditions} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Policy.create_platform_terms_and_conditions()

      platform_terms_and_conditions
    end

    test "list_platform_terms_and_conditions/0 returns all platform_terms_and_conditions" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()
      assert Policy.list_platform_terms_and_conditions() == [platform_terms_and_conditions]
    end

    test "get_platform_terms_and_conditions!/1 returns the platform_terms_and_conditions with given id" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()

      assert Policy.get_platform_terms_and_conditions!(platform_terms_and_conditions.id) ==
               platform_terms_and_conditions
    end

    test "create_platform_terms_and_conditions/1 with valid data creates a platform_terms_and_conditions" do
      assert {:ok, %PlatformTermsAndConditions{} = platform_terms_and_conditions} =
               Policy.create_platform_terms_and_conditions(@valid_attrs)

      assert platform_terms_and_conditions.country_id == 42

      assert platform_terms_and_conditions.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert platform_terms_and_conditions.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert platform_terms_and_conditions.type == "some type"
      assert platform_terms_and_conditions.url == "some url"
    end

    test "create_platform_terms_and_conditions/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Policy.create_platform_terms_and_conditions(@invalid_attrs)
    end

    test "update_platform_terms_and_conditions/2 with valid data updates the platform_terms_and_conditions" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()

      assert {:ok, %PlatformTermsAndConditions{} = platform_terms_and_conditions} =
               Policy.update_platform_terms_and_conditions(
                 platform_terms_and_conditions,
                 @update_attrs
               )

      assert platform_terms_and_conditions.country_id == 43

      assert platform_terms_and_conditions.end_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert platform_terms_and_conditions.start_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert platform_terms_and_conditions.type == "some updated type"
      assert platform_terms_and_conditions.url == "some updated url"
    end

    test "update_platform_terms_and_conditions/2 with invalid data returns error changeset" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Policy.update_platform_terms_and_conditions(
                 platform_terms_and_conditions,
                 @invalid_attrs
               )

      assert platform_terms_and_conditions ==
               Policy.get_platform_terms_and_conditions!(platform_terms_and_conditions.id)
    end

    test "delete_platform_terms_and_conditions/1 deletes the platform_terms_and_conditions" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()

      assert {:ok, %PlatformTermsAndConditions{}} =
               Policy.delete_platform_terms_and_conditions(platform_terms_and_conditions)

      assert_raise Ecto.NoResultsError, fn ->
        Policy.get_platform_terms_and_conditions!(platform_terms_and_conditions.id)
      end
    end

    test "change_platform_terms_and_conditions/1 returns a platform_terms_and_conditions changeset" do
      platform_terms_and_conditions = platform_terms_and_conditions_fixture()

      assert %Ecto.Changeset{} =
               Policy.change_platform_terms_and_conditions(platform_terms_and_conditions)
    end
  end
end
