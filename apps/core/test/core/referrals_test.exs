defmodule Core.ReferralsTest do
  use Core.DataCase

  alias Core.Referrals

  describe "user_referrals" do
    alias Core.Schemas.UserReferral

    @valid_attrs %{payment_method_setup: true, referral_code: "some referral_code"}
    @update_attrs %{payment_method_setup: false, referral_code: "some updated referral_code"}
    @invalid_attrs %{payment_method_setup: nil, referral_code: nil}

    def user_referral_fixture(attrs \\ %{}) do
      {:ok, user_referral} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Referrals.create_user_referral()

      user_referral
    end

    test "list_user_referrals/0 returns all user_referrals" do
      user_referral = user_referral_fixture()
      assert Referrals.list_user_referrals() == [user_referral]
    end

    test "get_user_referral!/1 returns the user_referral with given id" do
      user_referral = user_referral_fixture()
      assert Referrals.get_user_referral!(user_referral.id) == user_referral
    end

    test "create_user_referral/1 with valid data creates a user_referral" do
      assert {:ok, %UserReferral{} = user_referral} = Referrals.create_user_referral(@valid_attrs)
      assert user_referral.payment_method_setup == true
      assert user_referral.referral_code == "some referral_code"
    end

    test "create_user_referral/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Referrals.create_user_referral(@invalid_attrs)
    end

    test "update_user_referral/2 with valid data updates the user_referral" do
      user_referral = user_referral_fixture()

      assert {:ok, %UserReferral{} = user_referral} =
               Referrals.update_user_referral(user_referral, @update_attrs)

      assert user_referral.payment_method_setup == false
      assert user_referral.referral_code == "some updated referral_code"
    end

    test "update_user_referral/2 with invalid data returns error changeset" do
      user_referral = user_referral_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Referrals.update_user_referral(user_referral, @invalid_attrs)

      assert user_referral == Referrals.get_user_referral!(user_referral.id)
    end

    test "delete_user_referral/1 deletes the user_referral" do
      user_referral = user_referral_fixture()
      assert {:ok, %UserReferral{}} = Referrals.delete_user_referral(user_referral)
      assert_raise Ecto.NoResultsError, fn -> Referrals.get_user_referral!(user_referral.id) end
    end

    test "change_user_referral/1 returns a user_referral changeset" do
      user_referral = user_referral_fixture()
      assert %Ecto.Changeset{} = Referrals.change_user_referral(user_referral)
    end
  end
end
