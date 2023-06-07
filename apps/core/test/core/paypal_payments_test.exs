defmodule Core.PaypalPaymentsTest do
  use Core.DataCase

  alias Core.PaypalPayments

  describe "paypal_sellers" do
    alias Core.Schemas.PaypalSeller

    @valid_attrs %{partner_referral_id: "some partner_referral_id"}
    @update_attrs %{partner_referral_id: "some updated partner_referral_id"}
    @invalid_attrs %{partner_referral_id: nil}

    def paypal_seller_fixture(attrs \\ %{}) do
      {:ok, paypal_seller} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaypalPayments.create_paypal_seller()

      paypal_seller
    end

    test "list_paypal_sellers/0 returns all paypal_sellers" do
      paypal_seller = paypal_seller_fixture()
      assert PaypalPayments.list_paypal_sellers() == [paypal_seller]
    end

    test "get_paypal_seller!/1 returns the paypal_seller with given id" do
      paypal_seller = paypal_seller_fixture()
      assert PaypalPayments.get_paypal_seller!(paypal_seller.id) == paypal_seller
    end

    test "create_paypal_seller/1 with valid data creates a paypal_seller" do
      assert {:ok, %PaypalSeller{} = paypal_seller} =
               PaypalPayments.create_paypal_seller(@valid_attrs)

      assert paypal_seller.partner_referral_id == "some partner_referral_id"
    end

    test "create_paypal_seller/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PaypalPayments.create_paypal_seller(@invalid_attrs)
    end

    test "update_paypal_seller/2 with valid data updates the paypal_seller" do
      paypal_seller = paypal_seller_fixture()

      assert {:ok, %PaypalSeller{} = paypal_seller} =
               PaypalPayments.update_paypal_seller(paypal_seller, @update_attrs)

      assert paypal_seller.partner_referral_id == "some updated partner_referral_id"
    end

    test "update_paypal_seller/2 with invalid data returns error changeset" do
      paypal_seller = paypal_seller_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.update_paypal_seller(paypal_seller, @invalid_attrs)

      assert paypal_seller == PaypalPayments.get_paypal_seller!(paypal_seller.id)
    end

    test "delete_paypal_seller/1 deletes the paypal_seller" do
      paypal_seller = paypal_seller_fixture()
      assert {:ok, %PaypalSeller{}} = PaypalPayments.delete_paypal_seller(paypal_seller)

      assert_raise Ecto.NoResultsError, fn ->
        PaypalPayments.get_paypal_seller!(paypal_seller.id)
      end
    end

    test "change_paypal_seller/1 returns a paypal_seller changeset" do
      paypal_seller = paypal_seller_fixture()
      assert %Ecto.Changeset{} = PaypalPayments.change_paypal_seller(paypal_seller)
    end
  end

  describe "paypal_subscriptions" do
    alias Core.Schemas.PaypalSubscription

    @valid_attrs %{
      currency_symbol: "some currency_symbol",
      expiry_date: ~D[2010-04-17],
      paypal_subscriptions_id: "some paypal_subscriptions_id",
      start_date: ~D[2010-04-17],
      subscription_bsp_plan_id_id: "some subscription_bsp_plan_id_id"
    }
    @update_attrs %{
      currency_symbol: "some updated currency_symbol",
      expiry_date: ~D[2011-05-18],
      paypal_subscriptions_id: "some updated paypal_subscriptions_id",
      start_date: ~D[2011-05-18],
      subscription_bsp_plan_id_id: "some updated subscription_bsp_plan_id_id"
    }
    @invalid_attrs %{
      currency_symbol: nil,
      expiry_date: nil,
      paypal_subscriptions_id: nil,
      start_date: nil,
      subscription_bsp_plan_id_id: nil
    }

    def paypal_subscription_fixture(attrs \\ %{}) do
      {:ok, paypal_subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaypalPayments.create_paypal_subscription()

      paypal_subscription
    end

    test "list_paypal_subscriptions/0 returns all paypal_subscriptions" do
      paypal_subscription = paypal_subscription_fixture()
      assert PaypalPayments.list_paypal_subscriptions() == [paypal_subscription]
    end

    test "get_paypal_subscription!/1 returns the paypal_subscription with given id" do
      paypal_subscription = paypal_subscription_fixture()

      assert PaypalPayments.get_paypal_subscription!(paypal_subscription.id) ==
               paypal_subscription
    end

    test "create_paypal_subscription/1 with valid data creates a paypal_subscription" do
      assert {:ok, %PaypalSubscription{} = paypal_subscription} =
               PaypalPayments.create_paypal_subscription(@valid_attrs)

      assert paypal_subscription.currency_symbol == "some currency_symbol"
      assert paypal_subscription.expiry_date == ~D[2010-04-17]
      assert paypal_subscription.paypal_subscriptions_id == "some paypal_subscriptions_id"
      assert paypal_subscription.start_date == ~D[2010-04-17]
      assert paypal_subscription.subscription_bsp_plan_id_id == "some subscription_bsp_plan_id_id"
    end

    test "create_paypal_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.create_paypal_subscription(@invalid_attrs)
    end

    test "update_paypal_subscription/2 with valid data updates the paypal_subscription" do
      paypal_subscription = paypal_subscription_fixture()

      assert {:ok, %PaypalSubscription{} = paypal_subscription} =
               PaypalPayments.update_paypal_subscription(paypal_subscription, @update_attrs)

      assert paypal_subscription.currency_symbol == "some updated currency_symbol"
      assert paypal_subscription.expiry_date == ~D[2011-05-18]
      assert paypal_subscription.paypal_subscriptions_id == "some updated paypal_subscriptions_id"
      assert paypal_subscription.start_date == ~D[2011-05-18]

      assert paypal_subscription.subscription_bsp_plan_id_id ==
               "some updated subscription_bsp_plan_id_id"
    end

    test "update_paypal_subscription/2 with invalid data returns error changeset" do
      paypal_subscription = paypal_subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.update_paypal_subscription(paypal_subscription, @invalid_attrs)

      assert paypal_subscription ==
               PaypalPayments.get_paypal_subscription!(paypal_subscription.id)
    end

    test "delete_paypal_subscription/1 deletes the paypal_subscription" do
      paypal_subscription = paypal_subscription_fixture()

      assert {:ok, %PaypalSubscription{}} =
               PaypalPayments.delete_paypal_subscription(paypal_subscription)

      assert_raise Ecto.NoResultsError, fn ->
        PaypalPayments.get_paypal_subscription!(paypal_subscription.id)
      end
    end

    test "change_paypal_subscription/1 returns a paypal_subscription changeset" do
      paypal_subscription = paypal_subscription_fixture()
      assert %Ecto.Changeset{} = PaypalPayments.change_paypal_subscription(paypal_subscription)
    end
  end

  describe "payal_subscription_plans" do
    alias Core.PaypalPayments.PayalSubscriptionPlan

    @valid_attrs %{
      active: true,
      annual_price: 120.5,
      currency: "some currency",
      monthly_price: 120.5,
      name: "some name",
      plan_details: %{},
      slug: "some slug"
    }
    @update_attrs %{
      active: false,
      annual_price: 456.7,
      currency: "some updated currency",
      monthly_price: 456.7,
      name: "some updated name",
      plan_details: %{},
      slug: "some updated slug"
    }
    @invalid_attrs %{
      active: nil,
      annual_price: nil,
      currency: nil,
      monthly_price: nil,
      name: nil,
      plan_details: nil,
      slug: nil
    }

    def payal_subscription_plan_fixture(attrs \\ %{}) do
      {:ok, payal_subscription_plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaypalPayments.create_payal_subscription_plan()

      payal_subscription_plan
    end

    test "list_payal_subscription_plans/0 returns all payal_subscription_plans" do
      payal_subscription_plan = payal_subscription_plan_fixture()
      assert PaypalPayments.list_payal_subscription_plans() == [payal_subscription_plan]
    end

    test "get_payal_subscription_plan!/1 returns the payal_subscription_plan with given id" do
      payal_subscription_plan = payal_subscription_plan_fixture()

      assert PaypalPayments.get_payal_subscription_plan!(payal_subscription_plan.id) ==
               payal_subscription_plan
    end

    test "create_payal_subscription_plan/1 with valid data creates a payal_subscription_plan" do
      assert {:ok, %PayalSubscriptionPlan{} = payal_subscription_plan} =
               PaypalPayments.create_payal_subscription_plan(@valid_attrs)

      assert payal_subscription_plan.active == true
      assert payal_subscription_plan.annual_price == 120.5
      assert payal_subscription_plan.currency == "some currency"
      assert payal_subscription_plan.monthly_price == 120.5
      assert payal_subscription_plan.name == "some name"
      assert payal_subscription_plan.plan_details == %{}
      assert payal_subscription_plan.slug == "some slug"
    end

    test "create_payal_subscription_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.create_payal_subscription_plan(@invalid_attrs)
    end

    test "update_payal_subscription_plan/2 with valid data updates the payal_subscription_plan" do
      payal_subscription_plan = payal_subscription_plan_fixture()

      assert {:ok, %PayalSubscriptionPlan{} = payal_subscription_plan} =
               PaypalPayments.update_payal_subscription_plan(
                 payal_subscription_plan,
                 @update_attrs
               )

      assert payal_subscription_plan.active == false
      assert payal_subscription_plan.annual_price == 456.7
      assert payal_subscription_plan.currency == "some updated currency"
      assert payal_subscription_plan.monthly_price == 456.7
      assert payal_subscription_plan.name == "some updated name"
      assert payal_subscription_plan.plan_details == %{}
      assert payal_subscription_plan.slug == "some updated slug"
    end

    test "update_payal_subscription_plan/2 with invalid data returns error changeset" do
      payal_subscription_plan = payal_subscription_plan_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.update_payal_subscription_plan(
                 payal_subscription_plan,
                 @invalid_attrs
               )

      assert payal_subscription_plan ==
               PaypalPayments.get_payal_subscription_plan!(payal_subscription_plan.id)
    end

    test "delete_payal_subscription_plan/1 deletes the payal_subscription_plan" do
      payal_subscription_plan = payal_subscription_plan_fixture()

      assert {:ok, %PayalSubscriptionPlan{}} =
               PaypalPayments.delete_payal_subscription_plan(payal_subscription_plan)

      assert_raise Ecto.NoResultsError, fn ->
        PaypalPayments.get_payal_subscription_plan!(payal_subscription_plan.id)
      end
    end

    test "change_payal_subscription_plan/1 returns a payal_subscription_plan changeset" do
      payal_subscription_plan = payal_subscription_plan_fixture()

      assert %Ecto.Changeset{} =
               PaypalPayments.change_payal_subscription_plan(payal_subscription_plan)
    end
  end

  describe "payal_access_attributes" do
    alias Core.PaypalPayments.PayalAccessAttributes

    @valid_attrs %{
      access_token: "some access_token",
      partner_attribution_id: "some partner_attribution_id"
    }
    @update_attrs %{
      access_token: "some updated access_token",
      partner_attribution_id: "some updated partner_attribution_id"
    }
    @invalid_attrs %{access_token: nil, partner_attribution_id: nil}

    def payal_access_attributes_fixture(attrs \\ %{}) do
      {:ok, payal_access_attributes} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PaypalPayments.create_payal_access_attributes()

      payal_access_attributes
    end

    test "list_payal_access_attributes/0 returns all payal_access_attributes" do
      payal_access_attributes = payal_access_attributes_fixture()
      assert PaypalPayments.list_payal_access_attributes() == [payal_access_attributes]
    end

    test "get_payal_access_attributes!/1 returns the payal_access_attributes with given id" do
      payal_access_attributes = payal_access_attributes_fixture()

      assert PaypalPayments.get_payal_access_attributes!(payal_access_attributes.id) ==
               payal_access_attributes
    end

    test "create_payal_access_attributes/1 with valid data creates a payal_access_attributes" do
      assert {:ok, %PayalAccessAttributes{} = payal_access_attributes} =
               PaypalPayments.create_payal_access_attributes(@valid_attrs)

      assert payal_access_attributes.access_token == "some access_token"
      assert payal_access_attributes.partner_attribution_id == "some partner_attribution_id"
    end

    test "create_payal_access_attributes/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.create_payal_access_attributes(@invalid_attrs)
    end

    test "update_payal_access_attributes/2 with valid data updates the payal_access_attributes" do
      payal_access_attributes = payal_access_attributes_fixture()

      assert {:ok, %PayalAccessAttributes{} = payal_access_attributes} =
               PaypalPayments.update_payal_access_attributes(
                 payal_access_attributes,
                 @update_attrs
               )

      assert payal_access_attributes.access_token == "some updated access_token"

      assert payal_access_attributes.partner_attribution_id ==
               "some updated partner_attribution_id"
    end

    test "update_payal_access_attributes/2 with invalid data returns error changeset" do
      payal_access_attributes = payal_access_attributes_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PaypalPayments.update_payal_access_attributes(
                 payal_access_attributes,
                 @invalid_attrs
               )

      assert payal_access_attributes ==
               PaypalPayments.get_payal_access_attributes!(payal_access_attributes.id)
    end

    test "delete_payal_access_attributes/1 deletes the payal_access_attributes" do
      payal_access_attributes = payal_access_attributes_fixture()

      assert {:ok, %PayalAccessAttributes{}} =
               PaypalPayments.delete_payal_access_attributes(payal_access_attributes)

      assert_raise Ecto.NoResultsError, fn ->
        PaypalPayments.get_payal_access_attributes!(payal_access_attributes.id)
      end
    end

    test "change_payal_access_attributes/1 returns a payal_access_attributes changeset" do
      payal_access_attributes = payal_access_attributes_fixture()

      assert %Ecto.Changeset{} =
               PaypalPayments.change_payal_access_attributes(payal_access_attributes)
    end
  end
end
