defmodule Core.PaymentsTest do
  use Core.DataCase

  alias Core.Payments

  describe "brain_tree_tokens" do
    alias Core.Schemas.Payment

    @valid_attrs %{id: "some id", token: "some token"}
    @update_attrs %{id: "some updated id", token: "some updated token"}
    @invalid_attrs %{id: nil, token: nil}

    def payment_fixture(attrs \\ %{}) do
      {:ok, payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_payment()

      payment
    end

    test "list_brain_tree_tokens/0 returns all brain_tree_tokens" do
      payment = payment_fixture()
      assert Payments.list_brain_tree_tokens() == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment!(payment.id) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      assert {:ok, %Payment{} = payment} = Payments.create_payment(@valid_attrs)
      assert payment.id == "some id"
      assert payment.token == "some token"
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{} = payment} = Payments.update_payment(payment, @update_attrs)
      assert payment.id == "some updated id"
      assert payment.token == "some updated token"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_payment(payment, @invalid_attrs)
      assert payment == Payments.get_payment!(payment.id)
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Payments.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_payment(payment)
    end
  end

  describe "brain_tree_transactions" do
    alias Core.Payments.BrainTreeTransaction

    @valid_attrs %{id: "some id", transaction_id: "some transaction_id"}
    @update_attrs %{id: "some updated id", transaction_id: "some updated transaction_id"}
    @invalid_attrs %{id: nil, transaction_id: nil}

    def brain_tree_transaction_fixture(attrs \\ %{}) do
      {:ok, brain_tree_transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_transaction()

      brain_tree_transaction
    end

    test "list_brain_tree_transactions/0 returns all brain_tree_transactions" do
      brain_tree_transaction = brain_tree_transaction_fixture()
      assert Payments.list_brain_tree_transactions() == [brain_tree_transaction]
    end

    test "get_brain_tree_transaction!/1 returns the brain_tree_transaction with given id" do
      brain_tree_transaction = brain_tree_transaction_fixture()

      assert Payments.get_brain_tree_transaction!(brain_tree_transaction.id) ==
               brain_tree_transaction
    end

    test "create_brain_tree_transaction/1 with valid data creates a brain_tree_transaction" do
      assert {:ok, %BrainTreeTransaction{} = brain_tree_transaction} =
               Payments.create_brain_tree_transaction(@valid_attrs)

      assert brain_tree_transaction.id == "some id"
      assert brain_tree_transaction.transaction_id == "some transaction_id"
    end

    test "create_brain_tree_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_transaction(@invalid_attrs)
    end

    test "update_brain_tree_transaction/2 with valid data updates the brain_tree_transaction" do
      brain_tree_transaction = brain_tree_transaction_fixture()

      assert {:ok, %BrainTreeTransaction{} = brain_tree_transaction} =
               Payments.update_brain_tree_transaction(brain_tree_transaction, @update_attrs)

      assert brain_tree_transaction.id == "some updated id"
      assert brain_tree_transaction.transaction_id == "some updated transaction_id"
    end

    test "update_brain_tree_transaction/2 with invalid data returns error changeset" do
      brain_tree_transaction = brain_tree_transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_transaction(brain_tree_transaction, @invalid_attrs)

      assert brain_tree_transaction ==
               Payments.get_brain_tree_transaction!(brain_tree_transaction.id)
    end

    test "delete_brain_tree_transaction/1 deletes the brain_tree_transaction" do
      brain_tree_transaction = brain_tree_transaction_fixture()

      assert {:ok, %BrainTreeTransaction{}} =
               Payments.delete_brain_tree_transaction(brain_tree_transaction)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_transaction!(brain_tree_transaction.id)
      end
    end

    test "change_brain_tree_transaction/1 returns a brain_tree_transaction changeset" do
      brain_tree_transaction = brain_tree_transaction_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_transaction(brain_tree_transaction)
    end
  end

  describe "brain_tree_tokens" do
    alias Core.Schemas.BrainTreeTokens

    @valid_attrs %{id: "some id", token: "some token"}
    @update_attrs %{id: "some updated id", token: "some updated token"}
    @invalid_attrs %{id: nil, token: nil}

    def brain_tree_tokens_fixture(attrs \\ %{}) do
      {:ok, brain_tree_tokens} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_tokens()

      brain_tree_tokens
    end

    test "list_brain_tree_tokens/0 returns all brain_tree_tokens" do
      brain_tree_tokens = brain_tree_tokens_fixture()
      assert Payments.list_brain_tree_tokens() == [brain_tree_tokens]
    end

    test "get_brain_tree_tokens!/1 returns the brain_tree_tokens with given id" do
      brain_tree_tokens = brain_tree_tokens_fixture()
      assert Payments.get_brain_tree_tokens!(brain_tree_tokens.id) == brain_tree_tokens
    end

    test "create_brain_tree_tokens/1 with valid data creates a brain_tree_tokens" do
      assert {:ok, %BrainTreeTokens{} = brain_tree_tokens} =
               Payments.create_brain_tree_tokens(@valid_attrs)

      assert brain_tree_tokens.id == "some id"
      assert brain_tree_tokens.token == "some token"
    end

    test "create_brain_tree_tokens/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_tokens(@invalid_attrs)
    end

    test "update_brain_tree_tokens/2 with valid data updates the brain_tree_tokens" do
      brain_tree_tokens = brain_tree_tokens_fixture()

      assert {:ok, %BrainTreeTokens{} = brain_tree_tokens} =
               Payments.update_brain_tree_tokens(brain_tree_tokens, @update_attrs)

      assert brain_tree_tokens.id == "some updated id"
      assert brain_tree_tokens.token == "some updated token"
    end

    test "update_brain_tree_tokens/2 with invalid data returns error changeset" do
      brain_tree_tokens = brain_tree_tokens_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_tokens(brain_tree_tokens, @invalid_attrs)

      assert brain_tree_tokens == Payments.get_brain_tree_tokens!(brain_tree_tokens.id)
    end

    test "delete_brain_tree_tokens/1 deletes the brain_tree_tokens" do
      brain_tree_tokens = brain_tree_tokens_fixture()
      assert {:ok, %BrainTreeTokens{}} = Payments.delete_brain_tree_tokens(brain_tree_tokens)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_tokens!(brain_tree_tokens.id)
      end
    end

    test "change_brain_tree_tokens/1 returns a brain_tree_tokens changeset" do
      brain_tree_tokens = brain_tree_tokens_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_tokens(brain_tree_tokens)
    end
  end

  describe "brain_tree_wallets" do
    alias Core.Schemas.BrainTreeWallet

    @valid_attrs %{customer_id: "some customer_id", id: "some id"}
    @update_attrs %{customer_id: "some updated customer_id", id: "some updated id"}
    @invalid_attrs %{customer_id: nil, id: nil}

    def brain_tree_wallet_fixture(attrs \\ %{}) do
      {:ok, brain_tree_wallet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_wallet()

      brain_tree_wallet
    end

    test "list_brain_tree_wallets/0 returns all brain_tree_wallets" do
      brain_tree_wallet = brain_tree_wallet_fixture()
      assert Payments.list_brain_tree_wallets() == [brain_tree_wallet]
    end

    test "get_brain_tree_wallet!/1 returns the brain_tree_wallet with given id" do
      brain_tree_wallet = brain_tree_wallet_fixture()
      assert Payments.get_brain_tree_wallet!(brain_tree_wallet.id) == brain_tree_wallet
    end

    test "create_brain_tree_wallet/1 with valid data creates a brain_tree_wallet" do
      assert {:ok, %BrainTreeWallet{} = brain_tree_wallet} =
               Payments.create_brain_tree_wallet(@valid_attrs)

      assert brain_tree_wallet.customer_id == "some customer_id"
      assert brain_tree_wallet.id == "some id"
    end

    test "create_brain_tree_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_wallet(@invalid_attrs)
    end

    test "update_brain_tree_wallet/2 with valid data updates the brain_tree_wallet" do
      brain_tree_wallet = brain_tree_wallet_fixture()

      assert {:ok, %BrainTreeWallet{} = brain_tree_wallet} =
               Payments.update_brain_tree_wallet(brain_tree_wallet, @update_attrs)

      assert brain_tree_wallet.customer_id == "some updated customer_id"
      assert brain_tree_wallet.id == "some updated id"
    end

    test "update_brain_tree_wallet/2 with invalid data returns error changeset" do
      brain_tree_wallet = brain_tree_wallet_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_wallet(brain_tree_wallet, @invalid_attrs)

      assert brain_tree_wallet == Payments.get_brain_tree_wallet!(brain_tree_wallet.id)
    end

    test "delete_brain_tree_wallet/1 deletes the brain_tree_wallet" do
      brain_tree_wallet = brain_tree_wallet_fixture()
      assert {:ok, %BrainTreeWallet{}} = Payments.delete_brain_tree_wallet(brain_tree_wallet)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_wallet!(brain_tree_wallet.id)
      end
    end

    test "change_brain_tree_wallet/1 returns a brain_tree_wallet changeset" do
      brain_tree_wallet = brain_tree_wallet_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_wallet(brain_tree_wallet)
    end
  end

  describe "dispute_statuses" do
    alias Core.Schemas.DisputeStatus

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def dispute_status_fixture(attrs \\ %{}) do
      {:ok, dispute_status} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_dispute_status()

      dispute_status
    end

    test "list_dispute_statuses/0 returns all dispute_statuses" do
      dispute_status = dispute_status_fixture()
      assert Payments.list_dispute_statuses() == [dispute_status]
    end

    test "get_dispute_status!/1 returns the dispute_status with given id" do
      dispute_status = dispute_status_fixture()
      assert Payments.get_dispute_status!(dispute_status.id) == dispute_status
    end

    test "create_dispute_status/1 with valid data creates a dispute_status" do
      assert {:ok, %DisputeStatus{} = dispute_status} =
               Payments.create_dispute_status(@valid_attrs)

      assert dispute_status.description == "some description"
      assert dispute_status.id == "some id"
    end

    test "create_dispute_status/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_dispute_status(@invalid_attrs)
    end

    test "update_dispute_status/2 with valid data updates the dispute_status" do
      dispute_status = dispute_status_fixture()

      assert {:ok, %DisputeStatus{} = dispute_status} =
               Payments.update_dispute_status(dispute_status, @update_attrs)

      assert dispute_status.description == "some updated description"
      assert dispute_status.id == "some updated id"
    end

    test "update_dispute_status/2 with invalid data returns error changeset" do
      dispute_status = dispute_status_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_dispute_status(dispute_status, @invalid_attrs)

      assert dispute_status == Payments.get_dispute_status!(dispute_status.id)
    end

    test "delete_dispute_status/1 deletes the dispute_status" do
      dispute_status = dispute_status_fixture()
      assert {:ok, %DisputeStatus{}} = Payments.delete_dispute_status(dispute_status)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_dispute_status!(dispute_status.id) end
    end

    test "change_dispute_status/1 returns a dispute_status changeset" do
      dispute_status = dispute_status_fixture()
      assert %Ecto.Changeset{} = Payments.change_dispute_status(dispute_status)
    end
  end

  describe "dispute_categories" do
    alias Core.Schemas.DisputeCategory

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def dispute_category_fixture(attrs \\ %{}) do
      {:ok, dispute_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_dispute_category()

      dispute_category
    end

    test "list_dispute_categories/0 returns all dispute_categories" do
      dispute_category = dispute_category_fixture()
      assert Payments.list_dispute_categories() == [dispute_category]
    end

    test "get_dispute_category!/1 returns the dispute_category with given id" do
      dispute_category = dispute_category_fixture()
      assert Payments.get_dispute_category!(dispute_category.id) == dispute_category
    end

    test "create_dispute_category/1 with valid data creates a dispute_category" do
      assert {:ok, %DisputeCategory{} = dispute_category} =
               Payments.create_dispute_category(@valid_attrs)

      assert dispute_category.description == "some description"
      assert dispute_category.id == "some id"
    end

    test "create_dispute_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_dispute_category(@invalid_attrs)
    end

    test "update_dispute_category/2 with valid data updates the dispute_category" do
      dispute_category = dispute_category_fixture()

      assert {:ok, %DisputeCategory{} = dispute_category} =
               Payments.update_dispute_category(dispute_category, @update_attrs)

      assert dispute_category.description == "some updated description"
      assert dispute_category.id == "some updated id"
    end

    test "update_dispute_category/2 with invalid data returns error changeset" do
      dispute_category = dispute_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_dispute_category(dispute_category, @invalid_attrs)

      assert dispute_category == Payments.get_dispute_category!(dispute_category.id)
    end

    test "delete_dispute_category/1 deletes the dispute_category" do
      dispute_category = dispute_category_fixture()
      assert {:ok, %DisputeCategory{}} = Payments.delete_dispute_category(dispute_category)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_dispute_category!(dispute_category.id)
      end
    end

    test "change_dispute_category/1 returns a dispute_category changeset" do
      dispute_category = dispute_category_fixture()
      assert %Ecto.Changeset{} = Payments.change_dispute_category(dispute_category)
    end
  end

  describe "brain_tree_disputes" do
    alias Core.Schemas.BrainTreeDispute

    @valid_attrs %{
      attachments: [],
      description: "some description",
      dispute_email: "some dispute_email",
      dispute_phone: "some dispute_phone",
      id: "some id",
      title: "some title",
      transaction_id: "some transaction_id"
    }
    @update_attrs %{
      attachments: [],
      description: "some updated description",
      dispute_email: "some updated dispute_email",
      dispute_phone: "some updated dispute_phone",
      id: "some updated id",
      title: "some updated title",
      transaction_id: "some updated transaction_id"
    }
    @invalid_attrs %{
      attachments: nil,
      description: nil,
      dispute_email: nil,
      dispute_phone: nil,
      id: nil,
      title: nil,
      transaction_id: nil
    }

    def brain_tree_dispute_fixture(attrs \\ %{}) do
      {:ok, brain_tree_dispute} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_dispute()

      brain_tree_dispute
    end

    test "list_brain_tree_disputes/0 returns all brain_tree_disputes" do
      brain_tree_dispute = brain_tree_dispute_fixture()
      assert Payments.list_brain_tree_disputes() == [brain_tree_dispute]
    end

    test "get_brain_tree_dispute!/1 returns the brain_tree_dispute with given id" do
      brain_tree_dispute = brain_tree_dispute_fixture()
      assert Payments.get_brain_tree_dispute!(brain_tree_dispute.id) == brain_tree_dispute
    end

    test "create_brain_tree_dispute/1 with valid data creates a brain_tree_dispute" do
      assert {:ok, %BrainTreeDispute{} = brain_tree_dispute} =
               Payments.create_brain_tree_dispute(@valid_attrs)

      assert brain_tree_dispute.attachments == []
      assert brain_tree_dispute.description == "some description"
      assert brain_tree_dispute.dispute_email == "some dispute_email"
      assert brain_tree_dispute.dispute_phone == "some dispute_phone"
      assert brain_tree_dispute.id == "some id"
      assert brain_tree_dispute.title == "some title"
      assert brain_tree_dispute.transaction_id == "some transaction_id"
    end

    test "create_brain_tree_dispute/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_dispute(@invalid_attrs)
    end

    test "update_brain_tree_dispute/2 with valid data updates the brain_tree_dispute" do
      brain_tree_dispute = brain_tree_dispute_fixture()

      assert {:ok, %BrainTreeDispute{} = brain_tree_dispute} =
               Payments.update_brain_tree_dispute(brain_tree_dispute, @update_attrs)

      assert brain_tree_dispute.attachments == []
      assert brain_tree_dispute.description == "some updated description"
      assert brain_tree_dispute.dispute_email == "some updated dispute_email"
      assert brain_tree_dispute.dispute_phone == "some updated dispute_phone"
      assert brain_tree_dispute.id == "some updated id"
      assert brain_tree_dispute.title == "some updated title"
      assert brain_tree_dispute.transaction_id == "some updated transaction_id"
    end

    test "update_brain_tree_dispute/2 with invalid data returns error changeset" do
      brain_tree_dispute = brain_tree_dispute_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_dispute(brain_tree_dispute, @invalid_attrs)

      assert brain_tree_dispute == Payments.get_brain_tree_dispute!(brain_tree_dispute.id)
    end

    test "delete_brain_tree_dispute/1 deletes the brain_tree_dispute" do
      brain_tree_dispute = brain_tree_dispute_fixture()
      assert {:ok, %BrainTreeDispute{}} = Payments.delete_brain_tree_dispute(brain_tree_dispute)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_dispute!(brain_tree_dispute.id)
      end
    end

    test "change_brain_tree_dispute/1 returns a brain_tree_dispute changeset" do
      brain_tree_dispute = brain_tree_dispute_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_dispute(brain_tree_dispute)
    end
  end

  describe "brain_tree_payment_methods" do
    alias Core.Payments.BrainTreePaymentMethod

    @valid_attrs %{id: "some id", token: "some token"}
    @update_attrs %{id: "some updated id", token: "some updated token"}
    @invalid_attrs %{id: nil, token: nil}

    def brain_tree_payment_method_fixture(attrs \\ %{}) do
      {:ok, brain_tree_payment_method} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_payment_method()

      brain_tree_payment_method
    end

    test "list_brain_tree_payment_methods/0 returns all brain_tree_payment_methods" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()
      assert Payments.list_brain_tree_payment_methods() == [brain_tree_payment_method]
    end

    test "get_brain_tree_payment_method!/1 returns the brain_tree_payment_method with given id" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()

      assert Payments.get_brain_tree_payment_method!(brain_tree_payment_method.id) ==
               brain_tree_payment_method
    end

    test "create_brain_tree_payment_method/1 with valid data creates a brain_tree_payment_method" do
      assert {:ok, %BrainTreePaymentMethod{} = brain_tree_payment_method} =
               Payments.create_brain_tree_payment_method(@valid_attrs)

      assert brain_tree_payment_method.id == "some id"
      assert brain_tree_payment_method.token == "some token"
    end

    test "create_brain_tree_payment_method/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_brain_tree_payment_method(@invalid_attrs)
    end

    test "update_brain_tree_payment_method/2 with valid data updates the brain_tree_payment_method" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()

      assert {:ok, %BrainTreePaymentMethod{} = brain_tree_payment_method} =
               Payments.update_brain_tree_payment_method(brain_tree_payment_method, @update_attrs)

      assert brain_tree_payment_method.id == "some updated id"
      assert brain_tree_payment_method.token == "some updated token"
    end

    test "update_brain_tree_payment_method/2 with invalid data returns error changeset" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_payment_method(
                 brain_tree_payment_method,
                 @invalid_attrs
               )

      assert brain_tree_payment_method ==
               Payments.get_brain_tree_payment_method!(brain_tree_payment_method.id)
    end

    test "delete_brain_tree_payment_method/1 deletes the brain_tree_payment_method" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()

      assert {:ok, %BrainTreePaymentMethod{}} =
               Payments.delete_brain_tree_payment_method(brain_tree_payment_method)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_payment_method!(brain_tree_payment_method.id)
      end
    end

    test "change_brain_tree_payment_method/1 returns a brain_tree_payment_method changeset" do
      brain_tree_payment_method = brain_tree_payment_method_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_brain_tree_payment_method(brain_tree_payment_method)
    end
  end

  describe "brain_tree_subscriptions" do
    alias Core.Schemas.BrainTreeSubscription

    @valid_attrs %{id: "some id", subscription_id: "some subscription_id"}
    @update_attrs %{id: "some updated id", subscription_id: "some updated subscription_id"}
    @invalid_attrs %{id: nil, subscription_id: nil}

    def brain_tree_subscription_fixture(attrs \\ %{}) do
      {:ok, brain_tree_subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_subscription()

      brain_tree_subscription
    end

    test "list_brain_tree_subscriptions/0 returns all brain_tree_subscriptions" do
      brain_tree_subscription = brain_tree_subscription_fixture()
      assert Payments.list_brain_tree_subscriptions() == [brain_tree_subscription]
    end

    test "get_brain_tree_subscription!/1 returns the brain_tree_subscription with given id" do
      brain_tree_subscription = brain_tree_subscription_fixture()

      assert Payments.get_brain_tree_subscription!(brain_tree_subscription.id) ==
               brain_tree_subscription
    end

    test "create_brain_tree_subscription/1 with valid data creates a brain_tree_subscription" do
      assert {:ok, %BrainTreeSubscription{} = brain_tree_subscription} =
               Payments.create_brain_tree_subscription(@valid_attrs)

      assert brain_tree_subscription.id == "some id"
      assert brain_tree_subscription.subscription_id == "some subscription_id"
    end

    test "create_brain_tree_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_subscription(@invalid_attrs)
    end

    test "update_brain_tree_subscription/2 with valid data updates the brain_tree_subscription" do
      brain_tree_subscription = brain_tree_subscription_fixture()

      assert {:ok, %BrainTreeSubscription{} = brain_tree_subscription} =
               Payments.update_brain_tree_subscription(brain_tree_subscription, @update_attrs)

      assert brain_tree_subscription.id == "some updated id"
      assert brain_tree_subscription.subscription_id == "some updated subscription_id"
    end

    test "update_brain_tree_subscription/2 with invalid data returns error changeset" do
      brain_tree_subscription = brain_tree_subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_subscription(brain_tree_subscription, @invalid_attrs)

      assert brain_tree_subscription ==
               Payments.get_brain_tree_subscription!(brain_tree_subscription.id)
    end

    test "delete_brain_tree_subscription/1 deletes the brain_tree_subscription" do
      brain_tree_subscription = brain_tree_subscription_fixture()

      assert {:ok, %BrainTreeSubscription{}} =
               Payments.delete_brain_tree_subscription(brain_tree_subscription)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_subscription!(brain_tree_subscription.id)
      end
    end

    test "change_brain_tree_subscription/1 returns a brain_tree_subscription changeset" do
      brain_tree_subscription = brain_tree_subscription_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_subscription(brain_tree_subscription)
    end
  end

  describe "brain_tree_payment_method_types" do
    alias Core.Payments.BrainTreePaymentMethodType

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def brain_tree_payment_method_type_fixture(attrs \\ %{}) do
      {:ok, brain_tree_payment_method_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_payment_method_type()

      brain_tree_payment_method_type
    end

    test "list_brain_tree_payment_method_types/0 returns all brain_tree_payment_method_types" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()
      assert Payments.list_brain_tree_payment_method_types() == [brain_tree_payment_method_type]
    end

    test "get_brain_tree_payment_method_type!/1 returns the brain_tree_payment_method_type with given id" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()

      assert Payments.get_brain_tree_payment_method_type!(brain_tree_payment_method_type.id) ==
               brain_tree_payment_method_type
    end

    test "create_brain_tree_payment_method_type/1 with valid data creates a brain_tree_payment_method_type" do
      assert {:ok, %BrainTreePaymentMethodType{} = brain_tree_payment_method_type} =
               Payments.create_brain_tree_payment_method_type(@valid_attrs)

      assert brain_tree_payment_method_type.description == "some description"
      assert brain_tree_payment_method_type.id == "some id"
    end

    test "create_brain_tree_payment_method_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_brain_tree_payment_method_type(@invalid_attrs)
    end

    test "update_brain_tree_payment_method_type/2 with valid data updates the brain_tree_payment_method_type" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()

      assert {:ok, %BrainTreePaymentMethodType{} = brain_tree_payment_method_type} =
               Payments.update_brain_tree_payment_method_type(
                 brain_tree_payment_method_type,
                 @update_attrs
               )

      assert brain_tree_payment_method_type.description == "some updated description"
      assert brain_tree_payment_method_type.id == "some updated id"
    end

    test "update_brain_tree_payment_method_type/2 with invalid data returns error changeset" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_payment_method_type(
                 brain_tree_payment_method_type,
                 @invalid_attrs
               )

      assert brain_tree_payment_method_type ==
               Payments.get_brain_tree_payment_method_type!(brain_tree_payment_method_type.id)
    end

    test "delete_brain_tree_payment_method_type/1 deletes the brain_tree_payment_method_type" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()

      assert {:ok, %BrainTreePaymentMethodType{}} =
               Payments.delete_brain_tree_payment_method_type(brain_tree_payment_method_type)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_payment_method_type!(brain_tree_payment_method_type.id)
      end
    end

    test "change_brain_tree_payment_method_type/1 returns a brain_tree_payment_method_type changeset" do
      brain_tree_payment_method_type = brain_tree_payment_method_type_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_brain_tree_payment_method_type(brain_tree_payment_method_type)
    end
  end

  describe "brain_tree_merchants" do
    alias Core.Schemas.BrainTreeMerchant

    @valid_attrs %{id: "some id", merchant_account_id: "some merchant_account_id", primary: true}
    @update_attrs %{
      id: "some updated id",
      merchant_account_id: "some updated merchant_account_id",
      primary: false
    }
    @invalid_attrs %{id: nil, merchant_account_id: nil, primary: nil}

    def brain_tree_merchant_fixture(attrs \\ %{}) do
      {:ok, brain_tree_merchant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_merchant()

      brain_tree_merchant
    end

    test "list_brain_tree_merchants/0 returns all brain_tree_merchants" do
      brain_tree_merchant = brain_tree_merchant_fixture()
      assert Payments.list_brain_tree_merchants() == [brain_tree_merchant]
    end

    test "get_brain_tree_merchant!/1 returns the brain_tree_merchant with given id" do
      brain_tree_merchant = brain_tree_merchant_fixture()
      assert Payments.get_brain_tree_merchant!(brain_tree_merchant.id) == brain_tree_merchant
    end

    test "create_brain_tree_merchant/1 with valid data creates a brain_tree_merchant" do
      assert {:ok, %BrainTreeMerchant{} = brain_tree_merchant} =
               Payments.create_brain_tree_merchant(@valid_attrs)

      assert brain_tree_merchant.id == "some id"
      assert brain_tree_merchant.merchant_account_id == "some merchant_account_id"
      assert brain_tree_merchant.primary == true
    end

    test "create_brain_tree_merchant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_brain_tree_merchant(@invalid_attrs)
    end

    test "update_brain_tree_merchant/2 with valid data updates the brain_tree_merchant" do
      brain_tree_merchant = brain_tree_merchant_fixture()

      assert {:ok, %BrainTreeMerchant{} = brain_tree_merchant} =
               Payments.update_brain_tree_merchant(brain_tree_merchant, @update_attrs)

      assert brain_tree_merchant.id == "some updated id"
      assert brain_tree_merchant.merchant_account_id == "some updated merchant_account_id"
      assert brain_tree_merchant.primary == false
    end

    test "update_brain_tree_merchant/2 with invalid data returns error changeset" do
      brain_tree_merchant = brain_tree_merchant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_merchant(brain_tree_merchant, @invalid_attrs)

      assert brain_tree_merchant == Payments.get_brain_tree_merchant!(brain_tree_merchant.id)
    end

    test "delete_brain_tree_merchant/1 deletes the brain_tree_merchant" do
      brain_tree_merchant = brain_tree_merchant_fixture()

      assert {:ok, %BrainTreeMerchant{}} =
               Payments.delete_brain_tree_merchant(brain_tree_merchant)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_merchant!(brain_tree_merchant.id)
      end
    end

    test "change_brain_tree_merchant/1 returns a brain_tree_merchant changeset" do
      brain_tree_merchant = brain_tree_merchant_fixture()
      assert %Ecto.Changeset{} = Payments.change_brain_tree_merchant(brain_tree_merchant)
    end
  end

  describe "charitable_organizations" do
    alias Core.Schemas.CharitableOrganizations

    @valid_attrs %{
      address: %{},
      employees_count: 42,
      est_year: "2010-04-17T14:00:00Z",
      is_active: true,
      licence_expiry_date: "2010-04-17T14:00:00Z",
      licence_no: "some licence_no",
      licence_photos: [],
      name: "some name",
      personal_identification: %{},
      phone: "some phone",
      profile_pictures: [],
      rating: 120.5,
      settings: %{},
      zone_ids: []
    }
    @update_attrs %{
      address: %{},
      employees_count: 43,
      est_year: "2011-05-18T15:01:01Z",
      is_active: false,
      licence_expiry_date: "2011-05-18T15:01:01Z",
      licence_no: "some updated licence_no",
      licence_photos: [],
      name: "some updated name",
      personal_identification: %{},
      phone: "some updated phone",
      profile_pictures: [],
      rating: 456.7,
      settings: %{},
      zone_ids: []
    }
    @invalid_attrs %{
      address: nil,
      employees_count: nil,
      est_year: nil,
      is_active: nil,
      licence_expiry_date: nil,
      licence_no: nil,
      licence_photos: nil,
      name: nil,
      personal_identification: nil,
      phone: nil,
      profile_pictures: nil,
      rating: nil,
      settings: nil,
      zone_ids: nil
    }

    def charitable_organizations_fixture(attrs \\ %{}) do
      {:ok, charitable_organizations} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_charitable_organizations()

      charitable_organizations
    end

    test "list_charitable_organizations/0 returns all charitable_organizations" do
      charitable_organizations = charitable_organizations_fixture()
      assert Payments.list_charitable_organizations() == [charitable_organizations]
    end

    test "get_charitable_organizations!/1 returns the charitable_organizations with given id" do
      charitable_organizations = charitable_organizations_fixture()

      assert Payments.get_charitable_organizations!(charitable_organizations.id) ==
               charitable_organizations
    end

    test "create_charitable_organizations/1 with valid data creates a charitable_organizations" do
      assert {:ok, %CharitableOrganizations{} = charitable_organizations} =
               Payments.create_charitable_organizations(@valid_attrs)

      assert charitable_organizations.address == %{}
      assert charitable_organizations.employees_count == 42

      assert charitable_organizations.est_year ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert charitable_organizations.is_active == true

      assert charitable_organizations.licence_expiry_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert charitable_organizations.licence_no == "some licence_no"
      assert charitable_organizations.licence_photos == []
      assert charitable_organizations.name == "some name"
      assert charitable_organizations.personal_identification == %{}
      assert charitable_organizations.phone == "some phone"
      assert charitable_organizations.profile_pictures == []
      assert charitable_organizations.rating == 120.5
      assert charitable_organizations.settings == %{}
      assert charitable_organizations.zone_ids == []
    end

    test "create_charitable_organizations/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_charitable_organizations(@invalid_attrs)
    end

    test "update_charitable_organizations/2 with valid data updates the charitable_organizations" do
      charitable_organizations = charitable_organizations_fixture()

      assert {:ok, %CharitableOrganizations{} = charitable_organizations} =
               Payments.update_charitable_organizations(charitable_organizations, @update_attrs)

      assert charitable_organizations.address == %{}
      assert charitable_organizations.employees_count == 43

      assert charitable_organizations.est_year ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert charitable_organizations.is_active == false

      assert charitable_organizations.licence_expiry_date ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert charitable_organizations.licence_no == "some updated licence_no"
      assert charitable_organizations.licence_photos == []
      assert charitable_organizations.name == "some updated name"
      assert charitable_organizations.personal_identification == %{}
      assert charitable_organizations.phone == "some updated phone"
      assert charitable_organizations.profile_pictures == []
      assert charitable_organizations.rating == 456.7
      assert charitable_organizations.settings == %{}
      assert charitable_organizations.zone_ids == []
    end

    test "update_charitable_organizations/2 with invalid data returns error changeset" do
      charitable_organizations = charitable_organizations_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_charitable_organizations(charitable_organizations, @invalid_attrs)

      assert charitable_organizations ==
               Payments.get_charitable_organizations!(charitable_organizations.id)
    end

    test "delete_charitable_organizations/1 deletes the charitable_organizations" do
      charitable_organizations = charitable_organizations_fixture()

      assert {:ok, %CharitableOrganizations{}} =
               Payments.delete_charitable_organizations(charitable_organizations)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_charitable_organizations!(charitable_organizations.id)
      end
    end

    test "change_charitable_organizations/1 returns a charitable_organizations changeset" do
      charitable_organizations = charitable_organizations_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_charitable_organizations(charitable_organizations)
    end
  end

  describe "donations" do
    alias Core.Schemas.Donations

    @valid_attrs %{
      amount: 120.5,
      description: "some description",
      slug: "some slug",
      status: "some status",
      title: "some title",
      valid_from: "2010-04-17T14:00:00Z",
      valid_to: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      amount: 456.7,
      description: "some updated description",
      slug: "some updated slug",
      status: "some updated status",
      title: "some updated title",
      valid_from: "2011-05-18T15:01:01Z",
      valid_to: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{
      amount: nil,
      description: nil,
      slug: nil,
      status: nil,
      title: nil,
      valid_from: nil,
      valid_to: nil
    }

    def donations_fixture(attrs \\ %{}) do
      {:ok, donations} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_donations()

      donations
    end

    test "list_donations/0 returns all donations" do
      donations = donations_fixture()
      assert Payments.list_donations() == [donations]
    end

    test "get_donations!/1 returns the donations with given id" do
      donations = donations_fixture()
      assert Payments.get_donations!(donations.id) == donations
    end

    test "create_donations/1 with valid data creates a donations" do
      assert {:ok, %Donations{} = donations} = Payments.create_donations(@valid_attrs)
      assert donations.amount == 120.5
      assert donations.description == "some description"
      assert donations.slug == "some slug"
      assert donations.status == "some status"
      assert donations.title == "some title"
      assert donations.valid_from == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert donations.valid_to == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_donations/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_donations(@invalid_attrs)
    end

    test "update_donations/2 with valid data updates the donations" do
      donations = donations_fixture()
      assert {:ok, %Donations{} = donations} = Payments.update_donations(donations, @update_attrs)
      assert donations.amount == 456.7
      assert donations.description == "some updated description"
      assert donations.slug == "some updated slug"
      assert donations.status == "some updated status"
      assert donations.title == "some updated title"
      assert donations.valid_from == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert donations.valid_to == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_donations/2 with invalid data returns error changeset" do
      donations = donations_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_donations(donations, @invalid_attrs)
      assert donations == Payments.get_donations!(donations.id)
    end

    test "delete_donations/1 deletes the donations" do
      donations = donations_fixture()
      assert {:ok, %Donations{}} = Payments.delete_donations(donations)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_donations!(donations.id) end
    end

    test "change_donations/1 returns a donations changeset" do
      donations = donations_fixture()
      assert %Ecto.Changeset{} = Payments.change_donations(donations)
    end
  end

  describe "brain_tree_subscription_statuses" do
    alias Core.Schemas.BrainTreeSubscriptionStatuses

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def brain_tree_subscription_statuses_fixture(attrs \\ %{}) do
      {:ok, brain_tree_subscription_statuses} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_brain_tree_subscription_statuses()

      brain_tree_subscription_statuses
    end

    test "list_brain_tree_subscription_statuses/0 returns all brain_tree_subscription_statuses" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert Payments.list_brain_tree_subscription_statuses() == [
               brain_tree_subscription_statuses
             ]
    end

    test "get_brain_tree_subscription_statuses!/1 returns the brain_tree_subscription_statuses with given id" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert Payments.get_brain_tree_subscription_statuses!(brain_tree_subscription_statuses.id) ==
               brain_tree_subscription_statuses
    end

    test "create_brain_tree_subscription_statuses/1 with valid data creates a brain_tree_subscription_statuses" do
      assert {:ok, %BrainTreeSubscriptionStatuses{} = brain_tree_subscription_statuses} =
               Payments.create_brain_tree_subscription_statuses(@valid_attrs)

      assert brain_tree_subscription_statuses.description == "some description"
      assert brain_tree_subscription_statuses.id == "some id"
    end

    test "create_brain_tree_subscription_statuses/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_brain_tree_subscription_statuses(@invalid_attrs)
    end

    test "update_brain_tree_subscription_statuses/2 with valid data updates the brain_tree_subscription_statuses" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert {:ok, %BrainTreeSubscriptionStatuses{} = brain_tree_subscription_statuses} =
               Payments.update_brain_tree_subscription_statuses(
                 brain_tree_subscription_statuses,
                 @update_attrs
               )

      assert brain_tree_subscription_statuses.description == "some updated description"
      assert brain_tree_subscription_statuses.id == "some updated id"
    end

    test "update_brain_tree_subscription_statuses/2 with invalid data returns error changeset" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_brain_tree_subscription_statuses(
                 brain_tree_subscription_statuses,
                 @invalid_attrs
               )

      assert brain_tree_subscription_statuses ==
               Payments.get_brain_tree_subscription_statuses!(brain_tree_subscription_statuses.id)
    end

    test "delete_brain_tree_subscription_statuses/1 deletes the brain_tree_subscription_statuses" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert {:ok, %BrainTreeSubscriptionStatuses{}} =
               Payments.delete_brain_tree_subscription_statuses(brain_tree_subscription_statuses)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_brain_tree_subscription_statuses!(brain_tree_subscription_statuses.id)
      end
    end

    test "change_brain_tree_subscription_statuses/1 returns a brain_tree_subscription_statuses changeset" do
      brain_tree_subscription_statuses = brain_tree_subscription_statuses_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_brain_tree_subscription_statuses(brain_tree_subscription_statuses)
    end
  end

  describe "subscription_rules" do
    alias Core.Payments.SubscriptionRule

    @valid_attrs %{
      additional_branch_office_charges: 120.5,
      branch_offices: 42,
      bus_net: true,
      business_private_messaging: true,
      business_verification: true,
      consolidated_calendar: true,
      consumer_family_member: true,
      consumer_private_messaging: true,
      data_limit: 42,
      data_retention: 42,
      deals: true,
      job_search_apply: true,
      my_net: true,
      n_ter: true,
      package_name: "some package_name",
      package_slug: "some package_slug",
      service_appointments: "some service_appointments",
      task_events: true,
      tudo_portion_of_consumer_tip: 42
    }
    @update_attrs %{
      additional_branch_office_charges: 456.7,
      branch_offices: 43,
      bus_net: false,
      business_private_messaging: false,
      business_verification: false,
      consolidated_calendar: false,
      consumer_family_member: false,
      consumer_private_messaging: false,
      data_limit: 43,
      data_retention: 43,
      deals: false,
      job_search_apply: false,
      my_net: false,
      n_ter: false,
      package_name: "some updated package_name",
      package_slug: "some updated package_slug",
      service_appointments: "some updated service_appointments",
      task_events: false,
      tudo_portion_of_consumer_tip: 43
    }
    @invalid_attrs %{
      additional_branch_office_charges: nil,
      branch_offices: nil,
      bus_net: nil,
      business_private_messaging: nil,
      business_verification: nil,
      consolidated_calendar: nil,
      consumer_family_member: nil,
      consumer_private_messaging: nil,
      data_limit: nil,
      data_retention: nil,
      deals: nil,
      job_search_apply: nil,
      my_net: nil,
      n_ter: nil,
      package_name: nil,
      package_slug: nil,
      service_appointments: nil,
      task_events: nil,
      tudo_portion_of_consumer_tip: nil
    }

    def subscription_rule_fixture(attrs \\ %{}) do
      {:ok, subscription_rule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_subscription_rule()

      subscription_rule
    end

    test "list_subscription_rules/0 returns all subscription_rules" do
      subscription_rule = subscription_rule_fixture()
      assert Payments.list_subscription_rules() == [subscription_rule]
    end

    test "get_subscription_rule!/1 returns the subscription_rule with given id" do
      subscription_rule = subscription_rule_fixture()
      assert Payments.get_subscription_rule!(subscription_rule.id) == subscription_rule
    end

    test "create_subscription_rule/1 with valid data creates a subscription_rule" do
      assert {:ok, %SubscriptionRule{} = subscription_rule} =
               Payments.create_subscription_rule(@valid_attrs)

      assert subscription_rule.additional_branch_office_charges == 120.5
      assert subscription_rule.branch_offices == 42
      assert subscription_rule.bus_net == true
      assert subscription_rule.business_private_messaging == true
      assert subscription_rule.business_verification == true
      assert subscription_rule.consolidated_calendar == true
      assert subscription_rule.consumer_family_member == true
      assert subscription_rule.consumer_private_messaging == true
      assert subscription_rule.data_limit == 42
      assert subscription_rule.data_retention == 42
      assert subscription_rule.deals == true
      assert subscription_rule.job_search_apply == true
      assert subscription_rule.my_net == true
      assert subscription_rule.n_ter == true
      assert subscription_rule.package_name == "some package_name"
      assert subscription_rule.package_slug == "some package_slug"
      assert subscription_rule.service_appointments == "some service_appointments"
      assert subscription_rule.task_events == true
      assert subscription_rule.tudo_portion_of_consumer_tip == 42
    end

    test "create_subscription_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_subscription_rule(@invalid_attrs)
    end

    test "update_subscription_rule/2 with valid data updates the subscription_rule" do
      subscription_rule = subscription_rule_fixture()

      assert {:ok, %SubscriptionRule{} = subscription_rule} =
               Payments.update_subscription_rule(subscription_rule, @update_attrs)

      assert subscription_rule.additional_branch_office_charges == 456.7
      assert subscription_rule.branch_offices == 43
      assert subscription_rule.bus_net == false
      assert subscription_rule.business_private_messaging == false
      assert subscription_rule.business_verification == false
      assert subscription_rule.consolidated_calendar == false
      assert subscription_rule.consumer_family_member == false
      assert subscription_rule.consumer_private_messaging == false
      assert subscription_rule.data_limit == 43
      assert subscription_rule.data_retention == 43
      assert subscription_rule.deals == false
      assert subscription_rule.job_search_apply == false
      assert subscription_rule.my_net == false
      assert subscription_rule.n_ter == false
      assert subscription_rule.package_name == "some updated package_name"
      assert subscription_rule.package_slug == "some updated package_slug"
      assert subscription_rule.service_appointments == "some updated service_appointments"
      assert subscription_rule.task_events == false
      assert subscription_rule.tudo_portion_of_consumer_tip == 43
    end

    test "update_subscription_rule/2 with invalid data returns error changeset" do
      subscription_rule = subscription_rule_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_subscription_rule(subscription_rule, @invalid_attrs)

      assert subscription_rule == Payments.get_subscription_rule!(subscription_rule.id)
    end

    test "delete_subscription_rule/1 deletes the subscription_rule" do
      subscription_rule = subscription_rule_fixture()
      assert {:ok, %SubscriptionRule{}} = Payments.delete_subscription_rule(subscription_rule)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_subscription_rule!(subscription_rule.id)
      end
    end

    test "change_subscription_rule/1 returns a subscription_rule changeset" do
      subscription_rule = subscription_rule_fixture()
      assert %Ecto.Changeset{} = Payments.change_subscription_rule(subscription_rule)
    end
  end

  describe "promotion_purchase_price" do
    alias Core.Schemas.PromotionPurchasePrice

    @valid_attrs %{
      base_price: 120.5,
      broadcast_range: 42,
      discount_percentage: 120.5,
      discounts: [],
      promotion_cost: 120.5,
      promotion_total_cost: 120.5,
      tax_percentage: 120.5,
      taxes: []
    }
    @update_attrs %{
      base_price: 456.7,
      broadcast_range: 43,
      discount_percentage: 456.7,
      discounts: [],
      promotion_cost: 456.7,
      promotion_total_cost: 456.7,
      tax_percentage: 456.7,
      taxes: []
    }
    @invalid_attrs %{
      base_price: nil,
      broadcast_range: nil,
      discount_percentage: nil,
      discounts: nil,
      promotion_cost: nil,
      promotion_total_cost: nil,
      tax_percentage: nil,
      taxes: nil
    }

    def promotion_purchase_price_fixture(attrs \\ %{}) do
      {:ok, promotion_purchase_price} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_promotion_purchase_price()

      promotion_purchase_price
    end

    test "list_promotion_purchase_price/0 returns all promotion_purchase_price" do
      promotion_purchase_price = promotion_purchase_price_fixture()
      assert Payments.list_promotion_purchase_price() == [promotion_purchase_price]
    end

    test "get_promotion_purchase_price!/1 returns the promotion_purchase_price with given id" do
      promotion_purchase_price = promotion_purchase_price_fixture()

      assert Payments.get_promotion_purchase_price!(promotion_purchase_price.id) ==
               promotion_purchase_price
    end

    test "create_promotion_purchase_price/1 with valid data creates a promotion_purchase_price" do
      assert {:ok, %PromotionPurchasePrice{} = promotion_purchase_price} =
               Payments.create_promotion_purchase_price(@valid_attrs)

      assert promotion_purchase_price.base_price == 120.5
      assert promotion_purchase_price.broadcast_range == 42
      assert promotion_purchase_price.discount_percentage == 120.5
      assert promotion_purchase_price.discounts == []
      assert promotion_purchase_price.promotion_cost == 120.5
      assert promotion_purchase_price.promotion_total_cost == 120.5
      assert promotion_purchase_price.tax_percentage == 120.5
      assert promotion_purchase_price.taxes == []
    end

    test "create_promotion_purchase_price/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_promotion_purchase_price(@invalid_attrs)
    end

    test "update_promotion_purchase_price/2 with valid data updates the promotion_purchase_price" do
      promotion_purchase_price = promotion_purchase_price_fixture()

      assert {:ok, %PromotionPurchasePrice{} = promotion_purchase_price} =
               Payments.update_promotion_purchase_price(promotion_purchase_price, @update_attrs)

      assert promotion_purchase_price.base_price == 456.7
      assert promotion_purchase_price.broadcast_range == 43
      assert promotion_purchase_price.discount_percentage == 456.7
      assert promotion_purchase_price.discounts == []
      assert promotion_purchase_price.promotion_cost == 456.7
      assert promotion_purchase_price.promotion_total_cost == 456.7
      assert promotion_purchase_price.tax_percentage == 456.7
      assert promotion_purchase_price.taxes == []
    end

    test "update_promotion_purchase_price/2 with invalid data returns error changeset" do
      promotion_purchase_price = promotion_purchase_price_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_promotion_purchase_price(promotion_purchase_price, @invalid_attrs)

      assert promotion_purchase_price ==
               Payments.get_promotion_purchase_price!(promotion_purchase_price.id)
    end

    test "delete_promotion_purchase_price/1 deletes the promotion_purchase_price" do
      promotion_purchase_price = promotion_purchase_price_fixture()

      assert {:ok, %PromotionPurchasePrice{}} =
               Payments.delete_promotion_purchase_price(promotion_purchase_price)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_promotion_purchase_price!(promotion_purchase_price.id)
      end
    end

    test "change_promotion_purchase_price/1 returns a promotion_purchase_price changeset" do
      promotion_purchase_price = promotion_purchase_price_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_promotion_purchase_price(promotion_purchase_price)
    end
  end

  describe "subscription_rules" do
    alias Core.Payments.SubscriptionRule

    @valid_attrs %{
      my_net: true,
      service_appointments: "some service_appointments",
      show_adds: true,
      task_events: true,
      job_postings: 42,
      additional_branch_office_charges: 120.5,
      package_name: "some package_name",
      tudo_portion_of_consumer_tip: 42,
      additional_tenant_business_charges: 120.5,
      job_posting_validity: 42,
      job_search_apply: true,
      package_slug: "some package_slug",
      promotions: 42,
      business_verification: true,
      data_limit: 42,
      consolidated_calendar: true,
      consumer_private_messaging: true,
      branch_offices: 42,
      business_private_messaging: true,
      employees_count: 42,
      deals: true,
      bus_net: true,
      additional_job_posting_charges: 120.5,
      additional_promotion_charges: 120.5,
      reports_period: 42,
      additional_employee_charges: 120.5,
      promotion_validity: 42,
      payment_fee: true,
      data_retention: 42,
      tenant_business_providers: 42,
      n_ter: true,
      data_privacy: true,
      consumer_family_member: true
    }
    @update_attrs %{
      my_net: false,
      service_appointments: "some updated service_appointments",
      show_adds: false,
      task_events: false,
      job_postings: 43,
      additional_branch_office_charges: 456.7,
      package_name: "some updated package_name",
      tudo_portion_of_consumer_tip: 43,
      additional_tenant_business_charges: 456.7,
      job_posting_validity: 43,
      job_search_apply: false,
      package_slug: "some updated package_slug",
      promotions: 43,
      business_verification: false,
      data_limit: 43,
      consolidated_calendar: false,
      consumer_private_messaging: false,
      branch_offices: 43,
      business_private_messaging: false,
      employees_count: 43,
      deals: false,
      bus_net: false,
      additional_job_posting_charges: 456.7,
      additional_promotion_charges: 456.7,
      reports_period: 43,
      additional_employee_charges: 456.7,
      promotion_validity: 43,
      payment_fee: false,
      data_retention: 43,
      tenant_business_providers: 43,
      n_ter: false,
      data_privacy: false,
      consumer_family_member: false
    }
    @invalid_attrs %{
      my_net: nil,
      service_appointments: nil,
      show_adds: nil,
      task_events: nil,
      job_postings: nil,
      additional_branch_office_charges: nil,
      package_name: nil,
      tudo_portion_of_consumer_tip: nil,
      additional_tenant_business_charges: nil,
      job_posting_validity: nil,
      job_search_apply: nil,
      package_slug: nil,
      promotions: nil,
      business_verification: nil,
      data_limit: nil,
      consolidated_calendar: nil,
      consumer_private_messaging: nil,
      branch_offices: nil,
      business_private_messaging: nil,
      employees_count: nil,
      deals: nil,
      bus_net: nil,
      additional_job_posting_charges: nil,
      additional_promotion_charges: nil,
      reports_period: nil,
      additional_employee_charges: nil,
      promotion_validity: nil,
      payment_fee: nil,
      data_retention: nil,
      tenant_business_providers: nil,
      n_ter: nil,
      data_privacy: nil,
      consumer_family_member: nil
    }

    def subscription_rule_fixture(attrs \\ %{}) do
      {:ok, subscription_rule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_subscription_rule()

      subscription_rule
    end

    test "list_subscription_rules/0 returns all subscription_rules" do
      subscription_rule = subscription_rule_fixture()
      assert Payments.list_subscription_rules() == [subscription_rule]
    end

    test "get_subscription_rule!/1 returns the subscription_rule with given id" do
      subscription_rule = subscription_rule_fixture()
      assert Payments.get_subscription_rule!(subscription_rule.id) == subscription_rule
    end

    test "create_subscription_rule/1 with valid data creates a subscription_rule" do
      assert {:ok, %SubscriptionRule{} = subscription_rule} =
               Payments.create_subscription_rule(@valid_attrs)

      assert subscription_rule.consumer_family_member == true
      assert subscription_rule.data_privacy == true
      assert subscription_rule.n_ter == true
      assert subscription_rule.tenant_business_providers == 42
      assert subscription_rule.data_retention == 42
      assert subscription_rule.payment_fee == true
      assert subscription_rule.promotion_validity == 42
      assert subscription_rule.additional_employee_charges == 120.5
      assert subscription_rule.reports_period == 42
      assert subscription_rule.additional_promotion_charges == 120.5
      assert subscription_rule.additional_job_posting_charges == 120.5
      assert subscription_rule.bus_net == true
      assert subscription_rule.deals == true
      assert subscription_rule.employees_count == 42
      assert subscription_rule.business_private_messaging == true
      assert subscription_rule.branch_offices == 42
      assert subscription_rule.consumer_private_messaging == true
      assert subscription_rule.consolidated_calendar == true
      assert subscription_rule.data_limit == 42
      assert subscription_rule.business_verification == true
      assert subscription_rule.promotions == 42
      assert subscription_rule.package_slug == "some package_slug"
      assert subscription_rule.job_search_apply == true
      assert subscription_rule.job_posting_validity == 42
      assert subscription_rule.additional_tenant_business_charges == 120.5
      assert subscription_rule.tudo_portion_of_consumer_tip == 42
      assert subscription_rule.package_name == "some package_name"
      assert subscription_rule.additional_branch_office_charges == 120.5
      assert subscription_rule.job_postings == 42
      assert subscription_rule.task_events == true
      assert subscription_rule.show_adds == true
      assert subscription_rule.service_appointments == "some service_appointments"
      assert subscription_rule.my_net == true
    end

    test "create_subscription_rule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_subscription_rule(@invalid_attrs)
    end

    test "update_subscription_rule/2 with valid data updates the subscription_rule" do
      subscription_rule = subscription_rule_fixture()

      assert {:ok, %SubscriptionRule{} = subscription_rule} =
               Payments.update_subscription_rule(subscription_rule, @update_attrs)

      assert subscription_rule.consumer_family_member == false
      assert subscription_rule.data_privacy == false
      assert subscription_rule.n_ter == false
      assert subscription_rule.tenant_business_providers == 43
      assert subscription_rule.data_retention == 43
      assert subscription_rule.payment_fee == false
      assert subscription_rule.promotion_validity == 43
      assert subscription_rule.additional_employee_charges == 456.7
      assert subscription_rule.reports_period == 43
      assert subscription_rule.additional_promotion_charges == 456.7
      assert subscription_rule.additional_job_posting_charges == 456.7
      assert subscription_rule.bus_net == false
      assert subscription_rule.deals == false
      assert subscription_rule.employees_count == 43
      assert subscription_rule.business_private_messaging == false
      assert subscription_rule.branch_offices == 43
      assert subscription_rule.consumer_private_messaging == false
      assert subscription_rule.consolidated_calendar == false
      assert subscription_rule.data_limit == 43
      assert subscription_rule.business_verification == false
      assert subscription_rule.promotions == 43
      assert subscription_rule.package_slug == "some updated package_slug"
      assert subscription_rule.job_search_apply == false
      assert subscription_rule.job_posting_validity == 43
      assert subscription_rule.additional_tenant_business_charges == 456.7
      assert subscription_rule.tudo_portion_of_consumer_tip == 43
      assert subscription_rule.package_name == "some updated package_name"
      assert subscription_rule.additional_branch_office_charges == 456.7
      assert subscription_rule.job_postings == 43
      assert subscription_rule.task_events == false
      assert subscription_rule.show_adds == false
      assert subscription_rule.service_appointments == "some updated service_appointments"
      assert subscription_rule.my_net == false
    end

    test "update_subscription_rule/2 with invalid data returns error changeset" do
      subscription_rule = subscription_rule_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_subscription_rule(subscription_rule, @invalid_attrs)

      assert subscription_rule == Payments.get_subscription_rule!(subscription_rule.id)
    end

    test "delete_subscription_rule/1 deletes the subscription_rule" do
      subscription_rule = subscription_rule_fixture()
      assert {:ok, %SubscriptionRule{}} = Payments.delete_subscription_rule(subscription_rule)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_subscription_rule!(subscription_rule.id)
      end
    end

    test "change_subscription_rule/1 returns a subscription_rule changeset" do
      subscription_rule = subscription_rule_fixture()
      assert %Ecto.Changeset{} = Payments.change_subscription_rule(subscription_rule)
    end
  end

  describe "subscription_additional_items" do
    alias Core.Payments.SubscriptionAdditionalItems

    @valid_attrs %{
      begin_date: ~N[2010-04-17 14:00:00],
      expiry_date: ~N[2010-04-17 14:00:00],
      number_of_items: 42,
      slug: "some slug",
      total_amount: 120.5,
      unit_price: 120.5
    }
    @update_attrs %{
      begin_date: ~N[2011-05-18 15:01:01],
      expiry_date: ~N[2011-05-18 15:01:01],
      number_of_items: 43,
      slug: "some updated slug",
      total_amount: 456.7,
      unit_price: 456.7
    }
    @invalid_attrs %{
      begin_date: nil,
      expiry_date: nil,
      number_of_items: nil,
      slug: nil,
      total_amount: nil,
      unit_price: nil
    }

    def subscription_additional_items_fixture(attrs \\ %{}) do
      {:ok, subscription_additional_items} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_subscription_additional_items()

      subscription_additional_items
    end

    test "list_subscription_additional_items/0 returns all subscription_additional_items" do
      subscription_additional_items = subscription_additional_items_fixture()
      assert Payments.list_subscription_additional_items() == [subscription_additional_items]
    end

    test "get_subscription_additional_items!/1 returns the subscription_additional_items with given id" do
      subscription_additional_items = subscription_additional_items_fixture()

      assert Payments.get_subscription_additional_items!(subscription_additional_items.id) ==
               subscription_additional_items
    end

    test "create_subscription_additional_items/1 with valid data creates a subscription_additional_items" do
      assert {:ok, %SubscriptionAdditionalItems{} = subscription_additional_items} =
               Payments.create_subscription_additional_items(@valid_attrs)

      assert subscription_additional_items.begin_date == ~N[2010-04-17 14:00:00]
      assert subscription_additional_items.expiry_date == ~N[2010-04-17 14:00:00]
      assert subscription_additional_items.number_of_items == 42
      assert subscription_additional_items.slug == "some slug"
      assert subscription_additional_items.total_amount == 120.5
      assert subscription_additional_items.unit_price == 120.5
    end

    test "create_subscription_additional_items/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_subscription_additional_items(@invalid_attrs)
    end

    test "update_subscription_additional_items/2 with valid data updates the subscription_additional_items" do
      subscription_additional_items = subscription_additional_items_fixture()

      assert {:ok, %SubscriptionAdditionalItems{} = subscription_additional_items} =
               Payments.update_subscription_additional_items(
                 subscription_additional_items,
                 @update_attrs
               )

      assert subscription_additional_items.begin_date == ~N[2011-05-18 15:01:01]
      assert subscription_additional_items.expiry_date == ~N[2011-05-18 15:01:01]
      assert subscription_additional_items.number_of_items == 43
      assert subscription_additional_items.slug == "some updated slug"
      assert subscription_additional_items.total_amount == 456.7
      assert subscription_additional_items.unit_price == 456.7
    end

    test "update_subscription_additional_items/2 with invalid data returns error changeset" do
      subscription_additional_items = subscription_additional_items_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_subscription_additional_items(
                 subscription_additional_items,
                 @invalid_attrs
               )

      assert subscription_additional_items ==
               Payments.get_subscription_additional_items!(subscription_additional_items.id)
    end

    test "delete_subscription_additional_items/1 deletes the subscription_additional_items" do
      subscription_additional_items = subscription_additional_items_fixture()

      assert {:ok, %SubscriptionAdditionalItems{}} =
               Payments.delete_subscription_additional_items(subscription_additional_items)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_subscription_additional_items!(subscription_additional_items.id)
      end
    end

    test "change_subscription_additional_items/1 returns a subscription_additional_items changeset" do
      subscription_additional_items = subscription_additional_items_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_subscription_additional_items(subscription_additional_items)
    end
  end

  describe "hyper_waller_users" do
    alias Core.Schemas.HyperWalletUser

    @valid_attrs %{user_token: "some user_token"}
    @update_attrs %{user_token: "some updated user_token"}
    @invalid_attrs %{user_token: nil}

    def hyper_wallet_user_fixture(attrs \\ %{}) do
      {:ok, hyper_wallet_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_hyper_wallet_user()

      hyper_wallet_user
    end

    test "list_hyper_waller_users/0 returns all hyper_waller_users" do
      hyper_wallet_user = hyper_wallet_user_fixture()
      assert Payments.list_hyper_waller_users() == [hyper_wallet_user]
    end

    test "get_hyper_wallet_user!/1 returns the hyper_wallet_user with given id" do
      hyper_wallet_user = hyper_wallet_user_fixture()
      assert Payments.get_hyper_wallet_user!(hyper_wallet_user.id) == hyper_wallet_user
    end

    test "create_hyper_wallet_user/1 with valid data creates a hyper_wallet_user" do
      assert {:ok, %HyperWalletUser{} = hyper_wallet_user} =
               Payments.create_hyper_wallet_user(@valid_attrs)

      assert hyper_wallet_user.user_token == "some user_token"
    end

    test "create_hyper_wallet_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_hyper_wallet_user(@invalid_attrs)
    end

    test "update_hyper_wallet_user/2 with valid data updates the hyper_wallet_user" do
      hyper_wallet_user = hyper_wallet_user_fixture()

      assert {:ok, %HyperWalletUser{} = hyper_wallet_user} =
               Payments.update_hyper_wallet_user(hyper_wallet_user, @update_attrs)

      assert hyper_wallet_user.user_token == "some updated user_token"
    end

    test "update_hyper_wallet_user/2 with invalid data returns error changeset" do
      hyper_wallet_user = hyper_wallet_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_hyper_wallet_user(hyper_wallet_user, @invalid_attrs)

      assert hyper_wallet_user == Payments.get_hyper_wallet_user!(hyper_wallet_user.id)
    end

    test "delete_hyper_wallet_user/1 deletes the hyper_wallet_user" do
      hyper_wallet_user = hyper_wallet_user_fixture()
      assert {:ok, %HyperWalletUser{}} = Payments.delete_hyper_wallet_user(hyper_wallet_user)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_hyper_wallet_user!(hyper_wallet_user.id)
      end
    end

    test "change_hyper_wallet_user/1 returns a hyper_wallet_user changeset" do
      hyper_wallet_user = hyper_wallet_user_fixture()
      assert %Ecto.Changeset{} = Payments.change_hyper_wallet_user(hyper_wallet_user)
    end
  end

  describe "hyper_wallet_payments" do
    alias Core.Payments.HyperWalletPayment

    @valid_attrs %{payment_amount: 120.5, payment_token: "some payment_token"}
    @update_attrs %{payment_amount: 456.7, payment_token: "some updated payment_token"}
    @invalid_attrs %{payment_amount: nil, payment_token: nil}

    def hyper_wallet_payment_fixture(attrs \\ %{}) do
      {:ok, hyper_wallet_payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_hyper_wallet_payment()

      hyper_wallet_payment
    end

    test "list_hyper_wallet_payments/0 returns all hyper_wallet_payments" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()
      assert Payments.list_hyper_wallet_payments() == [hyper_wallet_payment]
    end

    test "get_hyper_wallet_payment!/1 returns the hyper_wallet_payment with given id" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()
      assert Payments.get_hyper_wallet_payment!(hyper_wallet_payment.id) == hyper_wallet_payment
    end

    test "create_hyper_wallet_payment/1 with valid data creates a hyper_wallet_payment" do
      assert {:ok, %HyperWalletPayment{} = hyper_wallet_payment} =
               Payments.create_hyper_wallet_payment(@valid_attrs)

      assert hyper_wallet_payment.payment_amount == 120.5
      assert hyper_wallet_payment.payment_token == "some payment_token"
    end

    test "create_hyper_wallet_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_hyper_wallet_payment(@invalid_attrs)
    end

    test "update_hyper_wallet_payment/2 with valid data updates the hyper_wallet_payment" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()

      assert {:ok, %HyperWalletPayment{} = hyper_wallet_payment} =
               Payments.update_hyper_wallet_payment(hyper_wallet_payment, @update_attrs)

      assert hyper_wallet_payment.payment_amount == 456.7
      assert hyper_wallet_payment.payment_token == "some updated payment_token"
    end

    test "update_hyper_wallet_payment/2 with invalid data returns error changeset" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_hyper_wallet_payment(hyper_wallet_payment, @invalid_attrs)

      assert hyper_wallet_payment == Payments.get_hyper_wallet_payment!(hyper_wallet_payment.id)
    end

    test "delete_hyper_wallet_payment/1 deletes the hyper_wallet_payment" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()

      assert {:ok, %HyperWalletPayment{}} =
               Payments.delete_hyper_wallet_payment(hyper_wallet_payment)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_hyper_wallet_payment!(hyper_wallet_payment.id)
      end
    end

    test "change_hyper_wallet_payment/1 returns a hyper_wallet_payment changeset" do
      hyper_wallet_payment = hyper_wallet_payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_hyper_wallet_payment(hyper_wallet_payment)
    end
  end

  describe "available_promotions" do
    alias Core.Payments.AvailablePromotion

    @valid_attrs %{
      additional: true,
      begin_at: "2010-04-17T14:00:00Z",
      broadcast_range: 120.5,
      expire_at: "2010-04-17T14:00:00Z",
      price: 120.5,
      title: "some title",
      used_at: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      additional: false,
      begin_at: "2011-05-18T15:01:01Z",
      broadcast_range: 456.7,
      expire_at: "2011-05-18T15:01:01Z",
      price: 456.7,
      title: "some updated title",
      used_at: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{
      additional: nil,
      begin_at: nil,
      broadcast_range: nil,
      expire_at: nil,
      price: nil,
      title: nil,
      used_at: nil
    }

    def available_promotion_fixture(attrs \\ %{}) do
      {:ok, available_promotion} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_available_promotion()

      available_promotion
    end

    test "list_available_promotions/0 returns all available_promotions" do
      available_promotion = available_promotion_fixture()
      assert Payments.list_available_promotions() == [available_promotion]
    end

    test "get_available_promotion!/1 returns the available_promotion with given id" do
      available_promotion = available_promotion_fixture()
      assert Payments.get_available_promotion!(available_promotion.id) == available_promotion
    end

    test "create_available_promotion/1 with valid data creates a available_promotion" do
      assert {:ok, %AvailablePromotion{} = available_promotion} =
               Payments.create_available_promotion(@valid_attrs)

      assert available_promotion.additional == true

      assert available_promotion.begin_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert available_promotion.broadcast_range == 120.5

      assert available_promotion.expire_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert available_promotion.price == 120.5
      assert available_promotion.title == "some title"

      assert available_promotion.used_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_available_promotion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_available_promotion(@invalid_attrs)
    end

    test "update_available_promotion/2 with valid data updates the available_promotion" do
      available_promotion = available_promotion_fixture()

      assert {:ok, %AvailablePromotion{} = available_promotion} =
               Payments.update_available_promotion(available_promotion, @update_attrs)

      assert available_promotion.additional == false

      assert available_promotion.begin_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert available_promotion.broadcast_range == 456.7

      assert available_promotion.expire_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert available_promotion.price == 456.7
      assert available_promotion.title == "some updated title"

      assert available_promotion.used_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_available_promotion/2 with invalid data returns error changeset" do
      available_promotion = available_promotion_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_available_promotion(available_promotion, @invalid_attrs)

      assert available_promotion == Payments.get_available_promotion!(available_promotion.id)
    end

    test "delete_available_promotion/1 deletes the available_promotion" do
      available_promotion = available_promotion_fixture()

      assert {:ok, %AvailablePromotion{}} =
               Payments.delete_available_promotion(available_promotion)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_available_promotion!(available_promotion.id)
      end
    end

    test "change_available_promotion/1 returns a available_promotion changeset" do
      available_promotion = available_promotion_fixture()
      assert %Ecto.Changeset{} = Payments.change_available_promotion(available_promotion)
    end
  end

  describe "earnings" do
    alias Core.Payments.Earning

    @valid_attrs %{available_amount: 120.5, pending_amount: 120.5, tudo_amount: 120.5}
    @update_attrs %{available_amount: 456.7, pending_amount: 456.7, tudo_amount: 456.7}
    @invalid_attrs %{available_amount: nil, pending_amount: nil, tudo_amount: nil}

    def earning_fixture(attrs \\ %{}) do
      {:ok, earning} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_earning()

      earning
    end

    test "list_earnings/0 returns all earnings" do
      earning = earning_fixture()
      assert Payments.list_earnings() == [earning]
    end

    test "get_earning!/1 returns the earning with given id" do
      earning = earning_fixture()
      assert Payments.get_earning!(earning.id) == earning
    end

    test "create_earning/1 with valid data creates a earning" do
      assert {:ok, %Earning{} = earning} = Payments.create_earning(@valid_attrs)
      assert earning.available_amount == 120.5
      assert earning.pending_amount == 120.5
      assert earning.tudo_amount == 120.5
    end

    test "create_earning/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_earning(@invalid_attrs)
    end

    test "update_earning/2 with valid data updates the earning" do
      earning = earning_fixture()
      assert {:ok, %Earning{} = earning} = Payments.update_earning(earning, @update_attrs)
      assert earning.available_amount == 456.7
      assert earning.pending_amount == 456.7
      assert earning.tudo_amount == 456.7
    end

    test "update_earning/2 with invalid data returns error changeset" do
      earning = earning_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_earning(earning, @invalid_attrs)
      assert earning == Payments.get_earning!(earning.id)
    end

    test "delete_earning/1 deletes the earning" do
      earning = earning_fixture()
      assert {:ok, %Earning{}} = Payments.delete_earning(earning)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_earning!(earning.id) end
    end

    test "change_earning/1 returns a earning changeset" do
      earning = earning_fixture()
      assert %Ecto.Changeset{} = Payments.change_earning(earning)
    end
  end

  describe "bsp_transfers" do
    alias Core.Schemas.BSPTransfer

    @valid_attrs %{amount: 120.5, hyperwallet_payment_token: "some hyperwallet_payment_token"}
    @update_attrs %{
      amount: 456.7,
      hyperwallet_payment_token: "some updated hyperwallet_payment_token"
    }
    @invalid_attrs %{amount: nil, hyperwallet_payment_token: nil}

    def bsp_transfer_fixture(attrs \\ %{}) do
      {:ok, bsp_transfer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_bsp_transfer()

      bsp_transfer
    end

    test "list_bsp_transfers/0 returns all bsp_transfers" do
      bsp_transfer = bsp_transfer_fixture()
      assert Payments.list_bsp_transfers() == [bsp_transfer]
    end

    test "get_bsp_transfer!/1 returns the bsp_transfer with given id" do
      bsp_transfer = bsp_transfer_fixture()
      assert Payments.get_bsp_transfer!(bsp_transfer.id) == bsp_transfer
    end

    test "create_bsp_transfer/1 with valid data creates a bsp_transfer" do
      assert {:ok, %BSPTransfer{} = bsp_transfer} = Payments.create_bsp_transfer(@valid_attrs)
      assert bsp_transfer.amount == 120.5
      assert bsp_transfer.hyperwallet_payment_token == "some hyperwallet_payment_token"
    end

    test "create_bsp_transfer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_bsp_transfer(@invalid_attrs)
    end

    test "update_bsp_transfer/2 with valid data updates the bsp_transfer" do
      bsp_transfer = bsp_transfer_fixture()

      assert {:ok, %BSPTransfer{} = bsp_transfer} =
               Payments.update_bsp_transfer(bsp_transfer, @update_attrs)

      assert bsp_transfer.amount == 456.7
      assert bsp_transfer.hyperwallet_payment_token == "some updated hyperwallet_payment_token"
    end

    test "update_bsp_transfer/2 with invalid data returns error changeset" do
      bsp_transfer = bsp_transfer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_bsp_transfer(bsp_transfer, @invalid_attrs)

      assert bsp_transfer == Payments.get_bsp_transfer!(bsp_transfer.id)
    end

    test "delete_bsp_transfer/1 deletes the bsp_transfer" do
      bsp_transfer = bsp_transfer_fixture()
      assert {:ok, %BSPTransfer{}} = Payments.delete_bsp_transfer(bsp_transfer)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_bsp_transfer!(bsp_transfer.id) end
    end

    test "change_bsp_transfer/1 returns a bsp_transfer changeset" do
      bsp_transfer = bsp_transfer_fixture()
      assert %Ecto.Changeset{} = Payments.change_bsp_transfer(bsp_transfer)
    end
  end

  describe "hyper_wallet_transfer_methods" do
    alias Core.Schemas.HyperWalletTransferMethod

    @valid_attrs %{is_default: true, token: "some token"}
    @update_attrs %{is_default: false, token: "some updated token"}
    @invalid_attrs %{is_default: nil, token: nil}

    def hyper_wallet_transfer_method_fixture(attrs \\ %{}) do
      {:ok, hyper_wallet_transfer_method} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_hyper_wallet_transfer_method()

      hyper_wallet_transfer_method
    end

    test "list_hyper_wallet_transfer_methods/0 returns all hyper_wallet_transfer_methods" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()
      assert Payments.list_hyper_wallet_transfer_methods() == [hyper_wallet_transfer_method]
    end

    test "get_hyper_wallet_transfer_method!/1 returns the hyper_wallet_transfer_method with given id" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()

      assert Payments.get_hyper_wallet_transfer_method!(hyper_wallet_transfer_method.id) ==
               hyper_wallet_transfer_method
    end

    test "create_hyper_wallet_transfer_method/1 with valid data creates a hyper_wallet_transfer_method" do
      assert {:ok, %HyperWalletTransferMethod{} = hyper_wallet_transfer_method} =
               Payments.create_hyper_wallet_transfer_method(@valid_attrs)

      assert hyper_wallet_transfer_method.is_default == true
      assert hyper_wallet_transfer_method.token == "some token"
    end

    test "create_hyper_wallet_transfer_method/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_hyper_wallet_transfer_method(@invalid_attrs)
    end

    test "update_hyper_wallet_transfer_method/2 with valid data updates the hyper_wallet_transfer_method" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()

      assert {:ok, %HyperWalletTransferMethod{} = hyper_wallet_transfer_method} =
               Payments.update_hyper_wallet_transfer_method(
                 hyper_wallet_transfer_method,
                 @update_attrs
               )

      assert hyper_wallet_transfer_method.is_default == false
      assert hyper_wallet_transfer_method.token == "some updated token"
    end

    test "update_hyper_wallet_transfer_method/2 with invalid data returns error changeset" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_hyper_wallet_transfer_method(
                 hyper_wallet_transfer_method,
                 @invalid_attrs
               )

      assert hyper_wallet_transfer_method ==
               Payments.get_hyper_wallet_transfer_method!(hyper_wallet_transfer_method.id)
    end

    test "delete_hyper_wallet_transfer_method/1 deletes the hyper_wallet_transfer_method" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()

      assert {:ok, %HyperWalletTransferMethod{}} =
               Payments.delete_hyper_wallet_transfer_method(hyper_wallet_transfer_method)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_hyper_wallet_transfer_method!(hyper_wallet_transfer_method.id)
      end
    end

    test "change_hyper_wallet_transfer_method/1 returns a hyper_wallet_transfer_method changeset" do
      hyper_wallet_transfer_method = hyper_wallet_transfer_method_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_hyper_wallet_transfer_method(hyper_wallet_transfer_method)
    end
  end

  describe "available_subscription_features" do
    alias Core.Schemas.AvailableSubscriptionFeature

    @valid_attrs %{
      begin_at: "2010-04-17T14:00:00Z",
      expire_at: "2010-04-17T14:00:00Z",
      price: 120.5,
      slug: "some slug",
      title: "some title",
      used_at: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      begin_at: "2011-05-18T15:01:01Z",
      expire_at: "2011-05-18T15:01:01Z",
      price: 456.7,
      slug: "some updated slug",
      title: "some updated title",
      used_at: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{
      begin_at: nil,
      expire_at: nil,
      price: nil,
      slug: nil,
      title: nil,
      used_at: nil
    }

    def available_subscription_feature_fixture(attrs \\ %{}) do
      {:ok, available_subscription_feature} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_available_subscription_feature()

      available_subscription_feature
    end

    test "list_available_subscription_features/0 returns all available_subscription_features" do
      available_subscription_feature = available_subscription_feature_fixture()
      assert Payments.list_available_subscription_features() == [available_subscription_feature]
    end

    test "get_available_subscription_feature!/1 returns the available_subscription_feature with given id" do
      available_subscription_feature = available_subscription_feature_fixture()

      assert Payments.get_available_subscription_feature!(available_subscription_feature.id) ==
               available_subscription_feature
    end

    test "create_available_subscription_feature/1 with valid data creates a available_subscription_feature" do
      assert {:ok, %AvailableSubscriptionFeature{} = available_subscription_feature} =
               Payments.create_available_subscription_feature(@valid_attrs)

      assert available_subscription_feature.begin_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert available_subscription_feature.expire_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert available_subscription_feature.price == 120.5
      assert available_subscription_feature.slug == "some slug"
      assert available_subscription_feature.title == "some title"

      assert available_subscription_feature.used_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_available_subscription_feature/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Payments.create_available_subscription_feature(@invalid_attrs)
    end

    test "update_available_subscription_feature/2 with valid data updates the available_subscription_feature" do
      available_subscription_feature = available_subscription_feature_fixture()

      assert {:ok, %AvailableSubscriptionFeature{} = available_subscription_feature} =
               Payments.update_available_subscription_feature(
                 available_subscription_feature,
                 @update_attrs
               )

      assert available_subscription_feature.begin_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert available_subscription_feature.expire_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert available_subscription_feature.price == 456.7
      assert available_subscription_feature.slug == "some updated slug"
      assert available_subscription_feature.title == "some updated title"

      assert available_subscription_feature.used_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_available_subscription_feature/2 with invalid data returns error changeset" do
      available_subscription_feature = available_subscription_feature_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Payments.update_available_subscription_feature(
                 available_subscription_feature,
                 @invalid_attrs
               )

      assert available_subscription_feature ==
               Payments.get_available_subscription_feature!(available_subscription_feature.id)
    end

    test "delete_available_subscription_feature/1 deletes the available_subscription_feature" do
      available_subscription_feature = available_subscription_feature_fixture()

      assert {:ok, %AvailableSubscriptionFeature{}} =
               Payments.delete_available_subscription_feature(available_subscription_feature)

      assert_raise Ecto.NoResultsError, fn ->
        Payments.get_available_subscription_feature!(available_subscription_feature.id)
      end
    end

    test "change_available_subscription_feature/1 returns a available_subscription_feature changeset" do
      available_subscription_feature = available_subscription_feature_fixture()

      assert %Ecto.Changeset{} =
               Payments.change_available_subscription_feature(available_subscription_feature)
    end
  end
end
