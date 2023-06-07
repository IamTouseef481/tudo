defmodule Core.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  import CoreWeb.Utils.Errors
  alias Core.Repo
  alias CoreWeb.Utils.DateTimeFunctions, as: DT

  alias Core.Schemas.{
    AvailableSubscriptionFeature,
    Balance,
    BrainTreeDispute,
    BrainTreeMerchant,
    BrainTreePaymentMethod,
    BrainTreeSubscription,
    BrainTreeSubscriptionStatuses,
    BrainTreeTokens,
    BrainTreeWallet,
    BSPTransfer,
    CharitableOrganization,
    DisputeCategory,
    DisputeStatus,
    Donation,
    HyperWalletTransferMethod,
    HyperWalletUser,
    Payment,
    PaymentMethod,
    PromotionPurchasePrice,
    SubscriptionBSPRule,
    SubscriptionCMRRule,
    PaymentStatus
  }

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments do
    Repo.all(Payment)
  end

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Brain tree transaction does not exist.

  ## Examples

      iex> get_payment!(123)
      %Payment{}

      iex> get_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment!(id), do: Repo.get!(Payment, id)
  def get_payment(id), do: Repo.get(Payment, id)

  def get_payment_status(id), do: Repo.get(PaymentStatus, id)

  def get_payment_by(%{user_id: user_id, transaction_id: transaction_id}) do
    from(p in Payment,
      where: p.user_id == ^user_id,
      where: p.braintree_transaction_id == ^transaction_id
    )
    |> Repo.all()
  end

  def get_cmr_paid_payments(%{user_id: user_id, from: from, to: to}) do
    from(p in Payment,
      where:
        p.user_id == ^user_id and p.from_cmr == true and p.cmr_payment_status_id == "active" and
          p.inserted_at >= ^from and p.inserted_at <= ^to,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_cmr_paid_payments(%{user_id: user_id, to: to}) do
    from(p in Payment,
      where:
        p.user_id == ^user_id and p.from_cmr == true and p.cmr_payment_status_id == "active" and
          p.inserted_at <= ^to,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_cmr_paid_payments(%{user_id: user_id, from: from}) do
    from(p in Payment,
      where:
        p.user_id == ^user_id and p.from_cmr == true and p.cmr_payment_status_id == "active" and
          p.inserted_at >= ^from,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_cmr_paid_payments(%{user_id: user_id}) do
    from(p in Payment,
      where: p.user_id == ^user_id and p.from_cmr == true and p.cmr_payment_status_id == "active",
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_earnings(%{branch_id: branch_id, status_id: status, from: from, to: to}) do
    from(p in Payment,
      where:
        p.branch_id == ^branch_id and p.from_cmr == true and p.bsp_payment_status_id == ^status and
          p.inserted_at >= ^from and p.inserted_at <= ^to,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_earnings(%{branch_id: branch_id, status_id: status, to: to}) do
    from(p in Payment,
      where:
        p.branch_id == ^branch_id and p.from_cmr == true and
          p.bsp_payment_status_id == ^status and p.inserted_at <= ^to,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_earnings(%{branch_id: branch_id, status_id: status, from: from}) do
    from(p in Payment,
      where:
        p.branch_id == ^branch_id and p.from_cmr == true and
          p.bsp_payment_status_id == ^status and p.inserted_at >= ^from,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_earnings(%{branch_id: branch_id, status_id: status}) do
    from(p in Payment,
      where:
        p.branch_id == ^branch_id and p.from_cmr == true and p.bsp_payment_status_id == ^status,
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_paid_payments(%{branch_id: branch_id}) do
    from(p in Payment,
      where:
        p.branch_id == ^branch_id and p.from_bsp == true and p.bsp_payment_status_id == "active",
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_bsp_paid_payments(%{business_id: business_id}) do
    from(p in Payment,
      where:
        p.business_id == ^business_id and p.from_bsp == true and
          p.bsp_payment_status_id == "active",
      order_by: [desc: p.paid_at]
    )
    |> Repo.all()
  end

  def get_payment_by_order_id(order_id) do
    from(p in Payment,
      where: fragment("? ->> ? = ?", p.payment_purpose, "order_id", ^"#{order_id}"),
      order_by: [desc: p.inserted_at]
    )
    |> Repo.one()
  end

  def get_payment_by_job_id(job_id) do
    from(p in Payment,
      where: fragment("? ->> ? = ?", p.payment_purpose, "job_id", ^"#{job_id}"),
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all()
  end

  def get_payment_by_invoice_id(invoice_id) do
    from(p in Payment,
      where: fragment("? ->> ? = ?", p.payment_purpose, "invoice_id", ^"#{invoice_id}"),
      limit: 1,
      order_by: [desc: p.inserted_at]
    )
    |> Repo.one()
  end

  def get_payment_by_subscription_id(subscription_id) do
    from(p in Payment,
      where:
        fragment(
          "? ->> ? = ?",
          p.payment_purpose,
          "paypal_subscription_id",
          ^"#{subscription_id}"
        ),
      limit: 1,
      order_by: [desc: p.inserted_at]
    )
    |> Repo.one()
  end

  def get_payment_by_transaction_id(transaction_id) do
    from(p in Payment,
      where: p.transaction_id == ^transaction_id,
      limit: 1,
      order_by: [desc: p.inserted_at]
    )
    |> Repo.one()
  end

  def get_default_zero_payment_by_business(business_id) do
    from(p in Payment,
      where:
        is_nil(p.transaction_id) and p.business_id == ^business_id and
          p.bsp_payment_status_id == "active" and p.total_transaction_amount == 0.0 and
          fragment("? \\? ?", p.payment_purpose, "paypal_subscription_id"),
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(attrs \\ %{}) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end

  def create_payment_status(attrs \\ %{}) do
    %PaymentStatus{}
    |> PaymentStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment.

  ## Examples

      iex> update_payment(payment, %{field: new_value})
      {:ok, %Payment{}}

      iex> update_payment(payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Payment.

  ## Examples

      iex> delete_payment(payment)
      {:ok, %Payment{}}

      iex> delete_payment(payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment changes.

  ## Examples

      iex> change_payment(payment)
      %Ecto.Changeset{source: %Payment{}}

  """
  def change_payment(%Payment{} = payment) do
    Payment.changeset(payment, %{})
  end

  @doc """
  Returns the list of brain_tree_tokens.

  ## Examples

      iex> list_brain_tree_tokens()
      [%BrainTreeTokens{}, ...]

  """
  def list_brain_tree_tokens do
    Repo.all(BrainTreeTokens)
  end

  @doc """
  Gets a single brain_tree_tokens.

  Raises `Ecto.NoResultsError` if the Brain tree tokens does not exist.

  ## Examples

      iex> get_brain_tree_tokens!(123)
      %BrainTreeTokens{}

      iex> get_brain_tree_tokens!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_tokens!(id), do: Repo.get!(BrainTreeTokens, id)

  @doc """
  Creates a brain_tree_tokens.

  ## Examples

      iex> create_brain_tree_tokens(%{field: value})
      {:ok, %BrainTreeTokens{}}

      iex> create_brain_tree_tokens(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_tokens(attrs \\ %{}) do
    %BrainTreeTokens{}
    |> BrainTreeTokens.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_tokens.

  ## Examples

      iex> update_brain_tree_tokens(brain_tree_tokens, %{field: new_value})
      {:ok, %BrainTreeTokens{}}

      iex> update_brain_tree_tokens(brain_tree_tokens, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_tokens(%BrainTreeTokens{} = brain_tree_tokens, attrs) do
    brain_tree_tokens
    |> BrainTreeTokens.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreeTokens.

  ## Examples

      iex> delete_brain_tree_tokens(brain_tree_tokens)
      {:ok, %BrainTreeTokens{}}

      iex> delete_brain_tree_tokens(brain_tree_tokens)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_tokens(%BrainTreeTokens{} = brain_tree_tokens) do
    Repo.delete(brain_tree_tokens)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_tokens changes.

  ## Examples

      iex> change_brain_tree_tokens(brain_tree_tokens)
      %Ecto.Changeset{source: %BrainTreeTokens{}}

  """
  def change_brain_tree_tokens(%BrainTreeTokens{} = brain_tree_tokens) do
    BrainTreeTokens.changeset(brain_tree_tokens, %{})
  end

  @doc """
  Returns the list of brain_tree_wallets.

  ## Examples

      iex> list_brain_tree_wallets()
      [%BrainTreeWallet{}, ...]

  """
  def list_brain_tree_wallets do
    Repo.all(BrainTreeWallet)
  end

  @doc """
  Gets a single brain_tree_wallet.

  Raises `Ecto.NoResultsError` if the Brain tree wallet does not exist.

  ## Examples

      iex> get_brain_tree_wallet!(123)
      %BrainTreeWallet{}

      iex> get_brain_tree_wallet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_wallet!(id), do: Repo.get!(BrainTreeWallet, id)

  def get_brain_tree_wallet_by(%{user_id: user_id}) do
    from(b in BrainTreeWallet, where: b.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Creates a brain_tree_wallet.

  ## Examples

      iex> create_brain_tree_wallet(%{field: value})
      {:ok, %BrainTreeWallet{}}

      iex> create_brain_tree_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_wallet(attrs \\ %{}) do
    %BrainTreeWallet{}
    |> BrainTreeWallet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_wallet.

  ## Examples

      iex> update_brain_tree_wallet(brain_tree_wallet, %{field: new_value})
      {:ok, %BrainTreeWallet{}}

      iex> update_brain_tree_wallet(brain_tree_wallet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_wallet(%BrainTreeWallet{} = brain_tree_wallet, attrs) do
    brain_tree_wallet
    |> BrainTreeWallet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreeWallet.

  ## Examples

      iex> delete_brain_tree_wallet(brain_tree_wallet)
      {:ok, %BrainTreeWallet{}}

      iex> delete_brain_tree_wallet(brain_tree_wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_wallet(%BrainTreeWallet{} = brain_tree_wallet) do
    Repo.delete(brain_tree_wallet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_wallet changes.

  ## Examples

      iex> change_brain_tree_wallet(brain_tree_wallet)
      %Ecto.Changeset{source: %BrainTreeWallet{}}

  """
  def change_brain_tree_wallet(%BrainTreeWallet{} = brain_tree_wallet) do
    BrainTreeWallet.changeset(brain_tree_wallet, %{})
  end

  @doc """
  Returns the list of dispute_statuses.

  ## Examples

      iex> list_dispute_statuses()
      [%DisputeStatus{}, ...]

  """
  def list_dispute_statuses do
    Repo.all(DisputeStatus)
  end

  @doc """
  Gets a single dispute_status.

  Raises `Ecto.NoResultsError` if the Dispute status does not exist.

  ## Examples

      iex> get_dispute_status!(123)
      %DisputeStatus{}

      iex> get_dispute_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dispute_status!(id), do: Repo.get!(DisputeStatus, id)
  def get_dispute_status(id), do: Repo.get(DisputeStatus, id)

  @doc """
  Creates a dispute_status.

  ## Examples

      iex> create_dispute_status(%{field: value})
      {:ok, %DisputeStatus{}}

      iex> create_dispute_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dispute_status(attrs \\ %{}) do
    %DisputeStatus{}
    |> DisputeStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dispute_status.

  ## Examples

      iex> update_dispute_status(dispute_status, %{field: new_value})
      {:ok, %DisputeStatus{}}

      iex> update_dispute_status(dispute_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dispute_status(%DisputeStatus{} = dispute_status, attrs) do
    dispute_status
    |> DisputeStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DisputeStatus.

  ## Examples

      iex> delete_dispute_status(dispute_status)
      {:ok, %DisputeStatus{}}

      iex> delete_dispute_status(dispute_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dispute_status(%DisputeStatus{} = dispute_status) do
    Repo.delete(dispute_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dispute_status changes.

  ## Examples

      iex> change_dispute_status(dispute_status)
      %Ecto.Changeset{source: %DisputeStatus{}}

  """
  def change_dispute_status(%DisputeStatus{} = dispute_status) do
    DisputeStatus.changeset(dispute_status, %{})
  end

  @doc """
  Returns the list of dispute_categories.

  ## Examples

      iex> list_dispute_categories()
      [%DisputeCategory{}, ...]

  """
  def list_dispute_categories do
    Repo.all(DisputeCategory)
  end

  @doc """
  Gets a single dispute_category.

  Raises `Ecto.NoResultsError` if the Dispute category does not exist.

  ## Examples

      iex> get_dispute_category!(123)
      %DisputeCategory{}

      iex> get_dispute_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dispute_category!(id), do: Repo.get!(DisputeCategory, id)
  def get_dispute_category(id), do: Repo.get(DisputeCategory, id)

  @doc """
  Creates a dispute_category.

  ## Examples

      iex> create_dispute_category(%{field: value})
      {:ok, %DisputeCategory{}}

      iex> create_dispute_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dispute_category(attrs \\ %{}) do
    %DisputeCategory{}
    |> DisputeCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dispute_category.

  ## Examples

      iex> update_dispute_category(dispute_category, %{field: new_value})
      {:ok, %DisputeCategory{}}

      iex> update_dispute_category(dispute_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dispute_category(%DisputeCategory{} = dispute_category, attrs) do
    dispute_category
    |> DisputeCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DisputeCategory.

  ## Examples

      iex> delete_dispute_category(dispute_category)
      {:ok, %DisputeCategory{}}

      iex> delete_dispute_category(dispute_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dispute_category(%DisputeCategory{} = dispute_category) do
    Repo.delete(dispute_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dispute_category changes.

  ## Examples

      iex> change_dispute_category(dispute_category)
      %Ecto.Changeset{source: %DisputeCategory{}}

  """
  def change_dispute_category(%DisputeCategory{} = dispute_category) do
    DisputeCategory.changeset(dispute_category, %{})
  end

  @doc """
  Returns the list of brain_tree_disputes.

  ## Examples

      iex> list_brain_tree_disputes()
      [%BrainTreeDispute{}, ...]

  """
  def list_brain_tree_disputes do
    Repo.all(BrainTreeDispute)
  end

  @doc """
  Gets a single brain_tree_dispute.

  Raises `Ecto.NoResultsError` if the Brain tree dispute does not exist.

  ## Examples

      iex> get_brain_tree_dispute!(123)
      %BrainTreeDispute{}

      iex> get_brain_tree_dispute!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_dispute!(id), do: Repo.get!(BrainTreeDispute, id)

  @doc """
  Creates a brain_tree_dispute.

  ## Examples

      iex> create_brain_tree_dispute(%{field: value})
      {:ok, %BrainTreeDispute{}}

      iex> create_brain_tree_dispute(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_dispute(attrs \\ %{}) do
    %BrainTreeDispute{}
    |> BrainTreeDispute.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_dispute.

  ## Examples

      iex> update_brain_tree_dispute(brain_tree_dispute, %{field: new_value})
      {:ok, %BrainTreeDispute{}}

      iex> update_brain_tree_dispute(brain_tree_dispute, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_dispute(%BrainTreeDispute{} = brain_tree_dispute, attrs) do
    brain_tree_dispute
    |> BrainTreeDispute.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreeDispute.

  ## Examples

      iex> delete_brain_tree_dispute(brain_tree_dispute)
      {:ok, %BrainTreeDispute{}}

      iex> delete_brain_tree_dispute(brain_tree_dispute)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_dispute(%BrainTreeDispute{} = brain_tree_dispute) do
    Repo.delete(brain_tree_dispute)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_dispute changes.

  ## Examples

      iex> change_brain_tree_dispute(brain_tree_dispute)
      %Ecto.Changeset{source: %BrainTreeDispute{}}

  """
  def change_brain_tree_dispute(%BrainTreeDispute{} = brain_tree_dispute) do
    BrainTreeDispute.changeset(brain_tree_dispute, %{})
  end

  @doc """
  Returns the list of brain_tree_payment_methods.

  ## Examples

      iex> list_brain_tree_payment_methods()
      [%BrainTreePaymentMethod{}, ...]

  """
  def list_brain_tree_payment_methods do
    Repo.all(BrainTreePaymentMethod)
  end

  def get_brain_tree_payment_method_by(%{token: token, customer_id: customer_id}) do
    from(b in BrainTreePaymentMethod,
      where: b.customer_id == ^customer_id,
      where: b.token == ^token
    )
    |> Repo.all()
  end

  def get_brain_tree_payment_method_by(%{customer_id: customer_id}) do
    from(b in BrainTreePaymentMethod, where: b.customer_id == ^customer_id)
    |> Repo.all()
  end

  def get_brain_tree_payment_method_by_token_and_customer(%{
        token: token,
        customer_id: customer_id
      }) do
    from(b in BrainTreePaymentMethod,
      where: b.customer_id == ^customer_id,
      where: b.token == ^token
    )
    |> Repo.one()
  end

  def get_brain_tree_default_payment_method_by_customer(id) do
    from(b in BrainTreePaymentMethod, where: b.customer_id == ^id and b.is_default)
    |> Repo.all()
  end

  def get_brain_tree_payment_methods_by(customer_id, card_number) do
    from(b in BrainTreePaymentMethod,
      where: b.customer_id == ^customer_id and b.card_number == ^card_number
    )
    |> Repo.all()
  end

  def get_brain_tree_payment_method_by_customer(id) do
    from(b in BrainTreePaymentMethod, where: b.customer_id == ^id)
    |> Repo.all()
  end

  @doc """
  Gets a single brain_tree_payment_method.

  Raises `Ecto.NoResultsError` if the Brain tree payment method does not exist.

  ## Examples

      iex> get_brain_tree_payment_method!(123)
      %BrainTreePaymentMethod{}

      iex> get_brain_tree_payment_method!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_payment_method!(id), do: Repo.get!(BrainTreePaymentMethod, id)

  @doc """
  Creates a brain_tree_payment_method.

  ## Examples

      iex> create_brain_tree_payment_method(%{field: value})
      {:ok, %BrainTreePaymentMethod{}}

      iex> create_brain_tree_payment_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_payment_method(attrs \\ %{}) do
    %BrainTreePaymentMethod{}
    |> BrainTreePaymentMethod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_payment_method.

  ## Examples

      iex> update_brain_tree_payment_method(brain_tree_payment_method, %{field: new_value})
      {:ok, %BrainTreePaymentMethod{}}

      iex> update_brain_tree_payment_method(brain_tree_payment_method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_payment_method(
        %BrainTreePaymentMethod{} = brain_tree_payment_method,
        attrs
      ) do
    brain_tree_payment_method
    |> BrainTreePaymentMethod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreePaymentMethod.

  ## Examples

      iex> delete_brain_tree_payment_method(brain_tree_payment_method)
      {:ok, %BrainTreePaymentMethod{}}

      iex> delete_brain_tree_payment_method(brain_tree_payment_method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_payment_method(%BrainTreePaymentMethod{} = brain_tree_payment_method) do
    Repo.delete(brain_tree_payment_method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_payment_method changes.

  ## Examples

      iex> change_brain_tree_payment_method(brain_tree_payment_method)
      %Ecto.Changeset{source: %BrainTreePaymentMethod{}}

  """
  def change_brain_tree_payment_method(%BrainTreePaymentMethod{} = brain_tree_payment_method) do
    BrainTreePaymentMethod.changeset(brain_tree_payment_method, %{})
  end

  @doc """
  Returns the list of brain_tree_subscriptions.

  ## Examples

      iex> list_brain_tree_subscriptions()
      [%BrainTreeSubscription{}, ...]

  """
  def list_brain_tree_subscriptions do
    Repo.all(BrainTreeSubscription)
  end

  @doc """
  Gets a single brain_tree_subscription.

  Raises `Ecto.NoResultsError` if the Brain tree subscription does not exist.

  ## Examples

      iex> get_brain_tree_subscription!(123)
      %BrainTreeSubscription{}

      iex> get_brain_tree_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_subscription!(id), do: Repo.get!(BrainTreeSubscription, id)
  def get_brain_tree_subscription(id), do: Repo.get(BrainTreeSubscription, id)

  def get_brain_tree_subscription_by_business(business_id) do
    from(s in BrainTreeSubscription,
      join: sr in SubscriptionBSPRule,
      on: sr.id == s.subscription_bsp_rule_id,
      where: s.business_id == ^business_id,
      preload: [subscription_bsp_rule: sr]
    )
    |> Repo.all()
  end

  def get_brain_tree_subscription_by_user_and_business(user_id, business_id) do
    from(s in BrainTreeSubscription,
      where: s.business_id == ^business_id and s.user_id == ^user_id
    )
    |> Repo.all()
  end

  def get_brain_tree_subscription_by(%{user_id: user_id, subscription_id: subscription_id}) do
    from(s in BrainTreeSubscription,
      where: s.user_id == ^user_id,
      where: s.subscription_id == ^subscription_id
    )
    |> Repo.all()
  end

  def get_brain_tree_subscription_by(%{subscription_id: subscription_id}) do
    from(s in BrainTreeSubscription,
      where: s.subscription_id == ^subscription_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a brain_tree_subscription.

  ## Examples

      iex> create_brain_tree_subscription(%{field: value})
      {:ok, %BrainTreeSubscription{}}

      iex> create_brain_tree_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_subscription(attrs \\ %{}) do
    %BrainTreeSubscription{}
    |> BrainTreeSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_subscription.

  ## Examples

      iex> update_brain_tree_subscription(brain_tree_subscription, %{field: new_value})
      {:ok, %BrainTreeSubscription{}}

      iex> update_brain_tree_subscription(brain_tree_subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_subscription(%BrainTreeSubscription{} = brain_tree_subscription, attrs) do
    brain_tree_subscription
    |> BrainTreeSubscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreeSubscription.

  ## Examples

      iex> delete_brain_tree_subscription(brain_tree_subscription)
      {:ok, %BrainTreeSubscription{}}

      iex> delete_brain_tree_subscription(brain_tree_subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_subscription(%BrainTreeSubscription{} = brain_tree_subscription) do
    Repo.delete(brain_tree_subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_subscription changes.

  ## Examples

      iex> change_brain_tree_subscription(brain_tree_subscription)
      %Ecto.Changeset{source: %BrainTreeSubscription{}}

  """
  def change_brain_tree_subscription(%BrainTreeSubscription{} = brain_tree_subscription) do
    BrainTreeSubscription.changeset(brain_tree_subscription, %{})
  end

  @doc """
  Returns the list of payment_methods.

  ## Examples

      iex> list_payment_methods()
      [%BrainTreePaymentMethodType{}, ...]

  """
  def list_payment_methods do
    Repo.all(PaymentMethod)
  end

  @doc """
  Gets a single payment_method.

  Raises `Ecto.NoResultsError` if the Brain tree payment method type does not exist.

  ## Examples

      iex> get_payment_method!(123)
      %PaymentMethod{}

      iex> get_payment_method!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_method!(id), do: Repo.get!(PaymentMethod, id)

  @doc """
  Creates a payment_method.

  ## Examples

      iex> create_payment_method(%{field: value})
      {:ok, %PaymentMethod{}}

      iex> create_payment_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_method(attrs \\ %{}) do
    %PaymentMethod{}
    |> PaymentMethod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_method.

  ## Examples

      iex> update_payment_method(payment_method, %{field: new_value})
      {:ok, %PaymentMethod{}}

      iex> update_payment_method(payment_method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_method(%PaymentMethod{} = payment_method, attrs) do
    payment_method
    |> PaymentMethod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PaymentMethod.

  ## Examples

      iex> delete_payment_method(payment_method)
      {:ok, %PaymentMethod{}}

      iex> delete_payment_method(payment_method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_method(%PaymentMethod{} = payment_method) do
    Repo.delete(payment_method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_method changes.

  ## Examples

      iex> change_payment_method(payment_method)
      %Ecto.Changeset{source: %PaymentMethod{}}

  """
  def change_payment_method(%PaymentMethod{} = payment_method) do
    PaymentMethod.changeset(payment_method, %{})
  end

  @doc """
  Returns the list of brain_tree_merchants.

  ## Examples

      iex> list_brain_tree_merchants()
      [%BrainTreeMerchant{}, ...]

  """
  def list_brain_tree_merchants do
    Repo.all(BrainTreeMerchant)
  end

  @doc """
  Gets a single brain_tree_merchant.

  Raises `Ecto.NoResultsError` if the Brain tree merchant does not exist.

  ## Examples

      iex> get_brain_tree_merchant!(123)
      %BrainTreeMerchant{}

      iex> get_brain_tree_merchant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_merchant!(id), do: Repo.get!(BrainTreeMerchant, id)

  def get_brain_tree_merchant_by(%{
        branch_id: branch_id,
        user_id: user_id,
        merchant_account_id: merchant_account_id
      }) do
    from(m in BrainTreeMerchant,
      where: m.branch_id == ^branch_id,
      where: m.user_id == ^user_id,
      where: m.merchant_account_id == ^merchant_account_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a brain_tree_merchant.

  ## Examples

      iex> create_brain_tree_merchant(%{field: value})
      {:ok, %BrainTreeMerchant{}}

      iex> create_brain_tree_merchant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_merchant(attrs \\ %{}) do
    %BrainTreeMerchant{}
    |> BrainTreeMerchant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_merchant.

  ## Examples

      iex> update_brain_tree_merchant(brain_tree_merchant, %{field: new_value})
      {:ok, %BrainTreeMerchant{}}

      iex> update_brain_tree_merchant(brain_tree_merchant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_merchant(%BrainTreeMerchant{} = brain_tree_merchant, attrs) do
    brain_tree_merchant
    |> BrainTreeMerchant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BrainTreeMerchant.

  ## Examples

      iex> delete_brain_tree_merchant(brain_tree_merchant)
      {:ok, %BrainTreeMerchant{}}

      iex> delete_brain_tree_merchant(brain_tree_merchant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_merchant(%BrainTreeMerchant{} = brain_tree_merchant) do
    Repo.delete(brain_tree_merchant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_merchant changes.

  ## Examples

      iex> change_brain_tree_merchant(brain_tree_merchant)
      %Ecto.Changeset{source: %BrainTreeMerchant{}}

  """
  def change_brain_tree_merchant(%BrainTreeMerchant{} = brain_tree_merchant) do
    BrainTreeMerchant.changeset(brain_tree_merchant, %{})
  end

  @doc """
  Returns the list of charitable_organization.

  ## Examples

      iex> list_charitable_organization()
      [%CharitableOrganization{}, ...]

  """
  def list_charitable_organization do
    Repo.all(CharitableOrganization)
  end

  @doc """
  Gets a single charitable_organization.

  Raises `Ecto.NoResultsError` if the Charitable organization does not exist.

  ## Examples

      iex> get_charitable_organization!(123)
      %CharitableOrganization{}

      iex> get_charitable_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_charitable_organization!(id), do: Repo.get!(CharitableOrganization, id)

  @doc """
  Creates a charitable_organization.

  ## Examples

      iex> create_charitable_organization(%{field: value})
      {:ok, %CharitableOrganization{}}

      iex> create_charitable_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_charitable_organization(attrs \\ %{}) do
    %CharitableOrganization{}
    |> CharitableOrganization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a charitable_organization.

  ## Examples

      iex> update_charitable_organization(charitable_organization, %{field: new_value})
      {:ok, %CharitableOrganization{}}

      iex> update_charitable_organization(charitable_organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_charitable_organization(%CharitableOrganization{} = charitable_organization, attrs) do
    charitable_organization
    |> CharitableOrganization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a charitable_organization.

  ## Examples

      iex> delete_charitable_organization(charitable_organization)
      {:ok, %CharitableOrganization{}}

      iex> delete_charitable_organization(charitable_organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_charitable_organization(%CharitableOrganization{} = charitable_organization) do
    Repo.delete(charitable_organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking charitable_organization changes.

  ## Examples

      iex> change_charitable_organization(charitable_organization)
      %Ecto.Changeset{source: %CharitableOrganization{}}

  """
  def change_charitable_organization(%CharitableOrganization{} = charitable_organization) do
    CharitableOrganization.changeset(charitable_organization, %{})
  end

  @doc """
  Returns the list of Donation.

  ## Examples

      iex> list_donation()
      [%Donation{}, ...]

  """
  def list_donation do
    Repo.all(Donation)
  end

  @doc """
  Gets a single Donation.

  Raises `Ecto.NoResultsError` if the Donation does not exist.

  ## Examples

      iex> get_Donation!(123)
      %Donation{}

      iex> get_Donation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_donation!(id), do: Repo.get!(Donation, id)
  def get_donation(id), do: Repo.get(Donation, id)
  def get_donation_by_slug(slug), do: Repo.get_by(Donation, %{slug: slug})

  def get_donations_by(%{valid_from: from, valid_to: to}) do
    Repo.all(
      from d in Donation,
        where: d.valid_from <= ^from and d.valid_to >= ^to and d.status == "active"
    )
  end

  def get_donations_by(%{valid_from: from}) do
    Repo.all(
      from d in Donation,
        where: d.valid_from <= ^from and d.status == "active"
    )
  end

  def get_donations_by(%{valid_to: to}) do
    Repo.all(
      from d in Donation,
        where: d.valid_to >= ^to and d.status == "active"
    )
  end

  def get_donations_by(_input) do
    Repo.all(from d in Donation, where: d.status == "active")
  end

  @doc """
  Creates a Donation.

  ## Examples

      iex> create_donation(%{field: value})
      {:ok, %donation{}}

      iex> create_donation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_donation(attrs \\ %{}) do
    %Donation{}
    |> Donation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Donation.

  ## Examples

      iex> update_donation(Donation, %{field: new_value})
      {:ok, %Donation{}}

      iex> update_donation(Donation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_donation(%Donation{} = donation, attrs) do
    donation
    |> Donation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Donation.

  ## Examples

      iex> delete_donation(Donation)
      {:ok, %Donation{}}

      iex> delete_donation(Donation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_donation(%Donation{} = donation) do
    Repo.delete(donation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking Donation changes.

  ## Examples

      iex> change_donation(Donation)
      %Ecto.Changeset{source: %Donation{}}

  """
  def change_donation(%Donation{} = donation) do
    Donation.changeset(donation, %{})
  end

  @doc """
  Returns the list of brain_tree_subscription_statuses.

  ## Examples

      iex> list_brain_tree_subscription_statuses()
      [%BrainTreeSubscriptionStatuses{}, ...]

  """
  def list_brain_tree_subscription_statuses do
    Repo.all(BrainTreeSubscriptionStatuses)
  end

  @doc """
  Gets a single brain_tree_subscription_statuses.

  Raises `Ecto.NoResultsError` if the Brain tree subscription statuses does not exist.

  ## Examples

      iex> get_brain_tree_subscription_statuses!(123)
      %BrainTreeSubscriptionStatuses{}

      iex> get_brain_tree_subscription_statuses!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brain_tree_subscription_statuses!(id), do: Repo.get!(BrainTreeSubscriptionStatuses, id)
  def get_brain_tree_subscription_statuses(id), do: Repo.get(BrainTreeSubscriptionStatuses, id)

  @doc """
  Creates a brain_tree_subscription_statuses.

  ## Examples

      iex> create_brain_tree_subscription_statuses(%{field: value})
      {:ok, %BrainTreeSubscriptionStatuses{}}

      iex> create_brain_tree_subscription_statuses(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brain_tree_subscription_statuses(attrs \\ %{}) do
    %BrainTreeSubscriptionStatuses{}
    |> BrainTreeSubscriptionStatuses.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brain_tree_subscription_statuses.

  ## Examples

      iex> update_brain_tree_subscription_statuses(brain_tree_subscription_statuses, %{field: new_value})
      {:ok, %BrainTreeSubscriptionStatuses{}}

      iex> update_brain_tree_subscription_statuses(brain_tree_subscription_statuses, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brain_tree_subscription_statuses(
        %BrainTreeSubscriptionStatuses{} = brain_tree_subscription_statuses,
        attrs
      ) do
    brain_tree_subscription_statuses
    |> BrainTreeSubscriptionStatuses.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brain_tree_subscription_statuses.

  ## Examples

      iex> delete_brain_tree_subscription_statuses(brain_tree_subscription_statuses)
      {:ok, %BrainTreeSubscriptionStatuses{}}

      iex> delete_brain_tree_subscription_statuses(brain_tree_subscription_statuses)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brain_tree_subscription_statuses(
        %BrainTreeSubscriptionStatuses{} = brain_tree_subscription_statuses
      ) do
    Repo.delete(brain_tree_subscription_statuses)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brain_tree_subscription_statuses changes.

  ## Examples

      iex> change_brain_tree_subscription_statuses(brain_tree_subscription_statuses)
      %Ecto.Changeset{source: %BrainTreeSubscriptionStatuses{}}

  """
  def change_brain_tree_subscription_statuses(
        %BrainTreeSubscriptionStatuses{} = brain_tree_subscription_statuses
      ) do
    BrainTreeSubscriptionStatuses.changeset(brain_tree_subscription_statuses, %{})
  end

  @doc """
  Returns the list of promotion_purchase_price.

  ## Examples

      iex> list_promotion_purchase_price()
      [%PromotionPurchasePrice{}, ...]

  """
  def list_promotion_purchase_price do
    Repo.all(PromotionPurchasePrice)
  end

  @doc """
  Gets a single promotion_purchase_price.

  Raises `Ecto.NoResultsError` if the Promotion purchase price does not exist.

  ## Examples

      iex> get_promotion_purchase_price!(123)
      %PromotionPurchasePrice{}

      iex> get_promotion_purchase_price!(456)
      ** (Ecto.NoResultsError)

  """
  def get_promotion_purchase_price!(id), do: Repo.get!(PromotionPurchasePrice, id)
  def get_promotion_purchase_price(id), do: Repo.get(PromotionPurchasePrice, id)

  def get_promotion_purchase_price_by_slug(slug) do
    from(p in PromotionPurchasePrice, where: p.slug == ^slug)
    |> Repo.all()
  end

  @doc """
  Creates a promotion_purchase_price.

  ## Examples

      iex> create_promotion_purchase_price(%{field: value})
      {:ok, %PromotionPurchasePrice{}}

      iex> create_promotion_purchase_price(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_promotion_purchase_price(attrs \\ %{}) do
    %PromotionPurchasePrice{}
    |> PromotionPurchasePrice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a promotion_purchase_price.

  ## Examples

      iex> update_promotion_purchase_price(promotion_purchase_price, %{field: new_value})
      {:ok, %PromotionPurchasePrice{}}

      iex> update_promotion_purchase_price(promotion_purchase_price, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_promotion_purchase_price(%PromotionPurchasePrice{} = promotion_purchase_price, attrs) do
    promotion_purchase_price
    |> PromotionPurchasePrice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a promotion_purchase_price.

  ## Examples

      iex> delete_promotion_purchase_price(promotion_purchase_price)
      {:ok, %PromotionPurchasePrice{}}

      iex> delete_promotion_purchase_price(promotion_purchase_price)
      {:error, %Ecto.Changeset{}}

  """
  def delete_promotion_purchase_price(%PromotionPurchasePrice{} = promotion_purchase_price) do
    Repo.delete(promotion_purchase_price)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking promotion_purchase_price changes.

  ## Examples

      iex> change_promotion_purchase_price(promotion_purchase_price)
      %Ecto.Changeset{source: %PromotionPurchasePrice{}}

  """
  def change_promotion_purchase_price(%PromotionPurchasePrice{} = promotion_purchase_price) do
    PromotionPurchasePrice.changeset(promotion_purchase_price, %{})
  end

  @doc """
  Returns the list of subscription_rules.

  ## Examples

      iex> list_subscription_rules()
      [%SubscriptionBSPRule{}, ...]

  """
  def list_subscription_bsp_rules do
    Repo.all(SubscriptionBSPRule)
  end

  @doc """
  Gets a single subscription_bsp_rule.

  Raises `Ecto.NoResultsError` if the Subscription rule does not exist.

  ## Examples

      iex> get_subscription_bsp_rule!(123)
      %SubscriptionBSPRule{}

      iex> get_subscription_bsp_rule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_bsp_rule!(id), do: Repo.get!(SubscriptionBSPRule, id)
  def get_subscription_bsp_rule(id), do: Repo.get(SubscriptionBSPRule, id)

  def get_subscription_bsp_rule_by_package_and_country(package_id, country_id) do
    from(sr in SubscriptionBSPRule,
      where:
        sr.package_id == ^package_id and
          (sr.country_id == ^country_id or sr.country_id == 1)
    )
    |> Repo.all()
  end

  def get_subscription_bsp_rule_by_slug_and_country(slug, country_id) do
    from(sr in SubscriptionBSPRule,
      where:
        sr.slug == ^slug and
          (sr.country_id == ^country_id or sr.country_id == 1)
    )
    |> Repo.all()
  end

  def get_subscription_bsp_rule_by_country(country_id) do
    from(sr in SubscriptionBSPRule, where: sr.country_id == ^country_id or sr.country_id == 1)
    |> Repo.all()
  end

  def get_subscription_bsp_rule_by_package_id(id) do
    Repo.get_by(SubscriptionBSPRule, %{package_id: id})
  rescue
    exception ->
      logger(__MODULE__, exception, exception.message, __ENV__.line)
  end

  @doc """
  Creates a subscription_bsp_rule.

  ## Examples

      iex> create_subscription_bsp_rule(%{field: value})
      {:ok, %SubscriptionBSPRule{}}

      iex> create_subscription_bsp_rule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_bsp_rule(attrs \\ %{}) do
    %SubscriptionBSPRule{}
    |> SubscriptionBSPRule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_bsp_rule.

  ## Examples

      iex> update_subscription_bsp_rule(subscription_bsp_rule, %{field: new_value})
      {:ok, %SubscriptionBSPRule{}}

      iex> update_subscription_bsp_rule(subscription_bsp_rule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_bsp_rule(%SubscriptionBSPRule{} = subscription_bsp_rule, attrs) do
    subscription_bsp_rule
    |> SubscriptionBSPRule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_bsp_rule.

  ## Examples

      iex> delete_subscription_bsp_rule(subscription_bsp_rule)
      {:ok, %SubscriptionBSPRule{}}

      iex> delete_subscription_bsp_rule(subscription_bsp_rule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_bsp_rule(%SubscriptionBSPRule{} = subscription_bsp_rule) do
    Repo.delete(subscription_bsp_rule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_bsp_rule changes.

  ## Examples

      iex> change_subscription_bsp_rule(subscription_bsp_rule)
      %Ecto.Changeset{source: %SubscriptionBSPRule{}}

  """
  def change_subscription_bsp_rule(%SubscriptionBSPRule{} = subscription_bsp_rule) do
    SubscriptionBSPRule.changeset(subscription_bsp_rule, %{})
  end

  @doc """
  Returns the list of subscription_cmr_rules.

  ## Examples

      iex> list_subscription_cmr_rules()
      [%SubscriptionCMRRule{}, ...]

  """
  def list_subscription_cmr_rules do
    Repo.all(SubscriptionCMRRule)
  end

  @doc """
  Gets a single subscription_cmr_rule.

  Raises `Ecto.NoResultsError` if the Subscription rule does not exist.

  ## Examples

      iex> get_subscription_cmr_rule!(123)
      %SubscriptionCMRRule{}

      iex> get_subscription_cmr_rule!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_cmr_rule!(id), do: Repo.get!(SubscriptionCMRRule, id)
  def get_subscription_cmr_rule(id), do: Repo.get(SubscriptionCMRRule, id)

  @doc """
  Creates a subscription_cmr_rule.

  ## Examples

      iex> create_subscription_cmr_rule(%{field: value})
      {:ok, %SubscriptionCMRRule{}}

      iex> create_subscription_cmr_rule(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_cmr_rule(attrs \\ %{}) do
    %SubscriptionCMRRule{}
    |> SubscriptionCMRRule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_cmr_rule.

  ## Examples

      iex> update_subscription_cmr_rule(subscription_cmr_rule, %{field: new_value})
      {:ok, %SubscriptionCMRRule{}}

      iex> update_subscription_cmr_rule(subscription_cmr_rule, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_cmr_rule(%SubscriptionCMRRule{} = subscription_cmr_rule, attrs) do
    subscription_cmr_rule
    |> SubscriptionCMRRule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_cmr_rule.

  ## Examples

      iex> delete_subscription_cmr_rule(subscription_cmr_rule)
      {:ok, %SubscriptionCMRRule{}}

      iex> delete_subscription_cmr_rule(subscription_cmr_rule)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_cmr_rule(%SubscriptionCMRRule{} = subscription_cmr_rule) do
    Repo.delete(subscription_cmr_rule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_cmr_rule changes.

  ## Examples

      iex> change_subscription_cmr_rule(subscription_cmr_rule)
      %Ecto.Changeset{source: %SubscriptionCMRRule{}}

  """
  def change_subscription_cmr_rule(%SubscriptionCMRRule{} = subscription_cmr_rule) do
    SubscriptionCMRRule.changeset(subscription_cmr_rule, %{})
  end

  @doc """
  Returns the list of hyper_waller_users.

  ## Examples

      iex> list_hyper_waller_users()
      [%HyperWalletUser{}, ...]

  """
  def list_hyper_waller_users do
    Repo.all(HyperWalletUser)
  end

  @doc """
  Gets a single hyper_wallet_user.

  Raises `Ecto.NoResultsError` if the Hyper wallet user does not exist.

  ## Examples

      iex> get_hyper_wallet_user!(123)
      %HyperWalletUser{}

      iex> get_hyper_wallet_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hyper_wallet_user!(id), do: Repo.get!(HyperWalletUser, id)

  def get_hyper_wallet_user_by(%{user_id: user_id}) do
    from(u in HyperWalletUser, where: u.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Creates a hyper_wallet_user.

  ## Examples

      iex> create_hyper_wallet_user(%{field: value})
      {:ok, %HyperWalletUser{}}

      iex> create_hyper_wallet_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hyper_wallet_user(attrs \\ %{}) do
    %HyperWalletUser{}
    |> HyperWalletUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hyper_wallet_user.

  ## Examples

      iex> update_hyper_wallet_user(hyper_wallet_user, %{field: new_value})
      {:ok, %HyperWalletUser{}}

      iex> update_hyper_wallet_user(hyper_wallet_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hyper_wallet_user(%HyperWalletUser{} = hyper_wallet_user, attrs) do
    hyper_wallet_user
    |> HyperWalletUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hyper_wallet_user.

  ## Examples

      iex> delete_hyper_wallet_user(hyper_wallet_user)
      {:ok, %HyperWalletUser{}}

      iex> delete_hyper_wallet_user(hyper_wallet_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hyper_wallet_user(%HyperWalletUser{} = hyper_wallet_user) do
    Repo.delete(hyper_wallet_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hyper_wallet_user changes.

  ## Examples

      iex> change_hyper_wallet_user(hyper_wallet_user)
      %Ecto.Changeset{source: %HyperWalletUser{}}

  """
  def change_hyper_wallet_user(%HyperWalletUser{} = hyper_wallet_user) do
    HyperWalletUser.changeset(hyper_wallet_user, %{})
  end

  @doc """
  Returns the list of balancess.

  ## Examples

      iex> list_balances()
      [%Balance{}, ...]

  """
  def list_balances do
    Repo.all(Balance)
  end

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(id), do: Repo.get!(Balance, id)
  def get_balance(id), do: Repo.get(Balance, id)
  def get_balance_by_branch(branch_id), do: Repo.get_by(Balance, %{branch_id: branch_id})
  def get_balance_by_business(business_id), do: Repo.get_by(Balance, %{business_id: business_id})
  def get_balance_by_cmr(user_id), do: Repo.get_by(Balance, %{user_id: user_id})

  def get_highest_bsp_earning do
    from(b in Balance, order_by: [desc: b.bsp_total_earning], limit: 1)
    |> Repo.one()
  end

  @doc """
  Creates a balance.

  ## Examples

      iex> create_balance(%{field: value})
      {:ok, %Balance{}}

      iex> create_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a balance.

  ## Examples

      iex> update_balance(balance, %{field: new_value})
      {:ok, %Balance{}}

      iex> update_balance(balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_balance(%Balance{} = balance, attrs) do
    balance
    |> Balance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a balance.

  ## Examples

      iex> delete_balance(balance)
      {:ok, %Balance{}}

      iex> delete_balance(balance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_balance(%Balance{} = balance) do
    Repo.delete(balance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking balance changes.

  ## Examples

      iex> change_balance(balance)
      %Ecto.Changeset{source: %Balance{}}

  """
  def change_balance(%Balance{} = balance) do
    Balance.changeset(balance, %{})
  end

  @doc """
  Returns the list of bsp_transfers.

  ## Examples

      iex> list_bsp_transfers()
      [%BSPTransfer{}, ...]

  """
  def list_bsp_transfers do
    Repo.all(BSPTransfer)
  end

  @doc """
  Gets a single bsp_transfer.

  Raises `Ecto.NoResultsError` if the Bsp transfer does not exist.

  ## Examples

      iex> get_bsp_transfer!(123)
      %BSPTransfer{}

      iex> get_bsp_transfer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bsp_transfer!(id), do: Repo.get!(BSPTransfer, id)
  def get_bsp_transfer(id), do: Repo.get(BSPTransfer, id)

  def get_bsp_transfers_by_branch(branch_id) do
    from(t in BSPTransfer, where: t.branch_id == ^branch_id)
    |> Repo.all()
  end

  def get_today_bsp_transfers_by_branch(branch_id) do
    start_time =
      DateTime.utc_now() |> Timex.beginning_of_day() |> DT.convert_utc_time_to_local_time()

    end_time = DateTime.utc_now() |> Timex.end_of_day() |> DT.convert_utc_time_to_local_time()

    from(t in BSPTransfer,
      where:
        t.branch_id == ^branch_id and t.inserted_at >= ^start_time and t.inserted_at <= ^end_time
    )
    |> Repo.all()
  end

  def get_today_total_bsp_transfer_by_branch(branch_id) do
    start_time =
      DateTime.utc_now() |> Timex.beginning_of_day() |> DT.convert_utc_time_to_local_time()

    end_time = DateTime.utc_now() |> Timex.end_of_day() |> DT.convert_utc_time_to_local_time()

    from(t in BSPTransfer,
      where:
        t.branch_id == ^branch_id and t.inserted_at >= ^start_time and t.inserted_at <= ^end_time,
      select: sum(t.amount)
    )
    |> Repo.one()
  end

  def get_total_bsp_transfer_by_branch(branch_id) do
    from(t in BSPTransfer, where: t.branch_id == ^branch_id, select: sum(t.amount))
    |> Repo.one()
  end

  def get_bsp_transfers_by(%{branch_id: branch_id, from: from, to: to}) do
    from(t in BSPTransfer,
      where: t.branch_id == ^branch_id and t.inserted_at >= ^from and t.inserted_at <= ^to
    )
    |> Repo.all()
  end

  def get_bsp_transfers_by(%{branch_id: branch_id, from: from}) do
    from(t in BSPTransfer,
      where: t.branch_id == ^branch_id and t.inserted_at >= ^from
    )
    |> Repo.all()
  end

  def get_bsp_transfers_by(%{branch_id: branch_id, to: to}) do
    from(t in BSPTransfer,
      where: t.branch_id == ^branch_id and t.inserted_at <= ^to
    )
    |> Repo.all()
  end

  def get_bsp_transfers_by(%{branch_id: branch_id}) do
    from(t in BSPTransfer, where: t.branch_id == ^branch_id)
    |> Repo.all()
  end

  @doc """
  Creates a bsp_transfer.

  ## Examples

      iex> create_bsp_transfer(%{field: value})
      {:ok, %BSPTransfer{}}

      iex> create_bsp_transfer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bsp_transfer(attrs \\ %{}) do
    %BSPTransfer{}
    |> BSPTransfer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bsp_transfer.

  ## Examples

      iex> update_bsp_transfer(bsp_transfer, %{field: new_value})
      {:ok, %BSPTransfer{}}

      iex> update_bsp_transfer(bsp_transfer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bsp_transfer(%BSPTransfer{} = bsp_transfer, attrs) do
    bsp_transfer
    |> BSPTransfer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bsp_transfer.

  ## Examples

      iex> delete_bsp_transfer(bsp_transfer)
      {:ok, %BSPTransfer{}}

      iex> delete_bsp_transfer(bsp_transfer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bsp_transfer(%BSPTransfer{} = bsp_transfer) do
    Repo.delete(bsp_transfer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bsp_transfer changes.

  ## Examples

      iex> change_bsp_transfer(bsp_transfer)
      %Ecto.Changeset{source: %BSPTransfer{}}

  """
  def change_bsp_transfer(%BSPTransfer{} = bsp_transfer) do
    BSPTransfer.changeset(bsp_transfer, %{})
  end

  @doc """
  Returns the list of hyper_wallet_transfer_methods.

  ## Examples

      iex> list_hyper_wallet_transfer_methods()
      [%HyperWalletTransferMethod{}, ...]

  """
  def list_hyper_wallet_transfer_methods do
    Repo.all(HyperWalletTransferMethod)
  end

  @doc """
  Gets a single hyper_wallet_transfer_method.

  Raises `Ecto.NoResultsError` if the Hyper wallet transfer method does not exist.

  ## Examples

      iex> get_hyper_wallet_transfer_method!(123)
      %HyperWalletTransferMethod{}

      iex> get_hyper_wallet_transfer_method!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hyper_wallet_transfer_method!(id), do: Repo.get!(HyperWalletTransferMethod, id)
  def get_hyper_wallet_transfer_method(id), do: Repo.get(HyperWalletTransferMethod, id)

  def get_hyper_wallet_transfer_methods_by_hw_user(hw_user_id) do
    from(tm in HyperWalletTransferMethod, where: tm.hw_user_id == ^hw_user_id)
    |> Repo.all()
  end

  def get_hyper_wallet_transfer_method_by_id_and_user(hw_user_id, tm_id) do
    from(tm in HyperWalletTransferMethod, where: tm.hw_user_id == ^hw_user_id and tm.id == ^tm_id)
    |> Repo.one()
  end

  @doc """
  Creates a hyper_wallet_transfer_method.

  ## Examples

      iex> create_hyper_wallet_transfer_method(%{field: value})
      {:ok, %HyperWalletTransferMethod{}}

      iex> create_hyper_wallet_transfer_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hyper_wallet_transfer_method(attrs \\ %{}) do
    %HyperWalletTransferMethod{}
    |> HyperWalletTransferMethod.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hyper_wallet_transfer_method.

  ## Examples

      iex> update_hyper_wallet_transfer_method(hyper_wallet_transfer_method, %{field: new_value})
      {:ok, %HyperWalletTransferMethod{}}

      iex> update_hyper_wallet_transfer_method(hyper_wallet_transfer_method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hyper_wallet_transfer_method(
        %HyperWalletTransferMethod{} = hyper_wallet_transfer_method,
        attrs
      ) do
    hyper_wallet_transfer_method
    |> HyperWalletTransferMethod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hyper_wallet_transfer_method.

  ## Examples

      iex> delete_hyper_wallet_transfer_method(hyper_wallet_transfer_method)
      {:ok, %HyperWalletTransferMethod{}}

      iex> delete_hyper_wallet_transfer_method(hyper_wallet_transfer_method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hyper_wallet_transfer_method(
        %HyperWalletTransferMethod{} = hyper_wallet_transfer_method
      ) do
    Repo.delete(hyper_wallet_transfer_method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hyper_wallet_transfer_method changes.

  ## Examples

      iex> change_hyper_wallet_transfer_method(hyper_wallet_transfer_method)
      %Ecto.Changeset{source: %HyperWalletTransferMethod{}}

  """
  def change_hyper_wallet_transfer_method(
        %HyperWalletTransferMethod{} = hyper_wallet_transfer_method
      ) do
    HyperWalletTransferMethod.changeset(hyper_wallet_transfer_method, %{})
  end

  @doc """
  Returns the list of available_subscription_features.

  ## Examples

      iex> list_available_subscription_features()
      [%AvailableSubscriptionFeature{}, ...]

  """
  def list_available_subscription_features do
    Repo.all(AvailableSubscriptionFeature)
  end

  @doc """
  Gets a single available_subscription_feature.

  Raises `Ecto.NoResultsError` if the Available subscription feature does not exist.

  ## Examples

      iex> get_available_subscription_feature!(123)
      %AvailableSubscriptionFeature{}

      iex> get_available_subscription_feature!(456)
      ** (Ecto.NoResultsError)

  """
  def get_available_subscription_feature!(id), do: Repo.get!(AvailableSubscriptionFeature, id)
  def get_available_subscription_feature(id), do: Repo.get(AvailableSubscriptionFeature, id)

  def get_available_subscription_feature_by_branch(id) do
    time = DateTime.utc_now()

    from(f in AvailableSubscriptionFeature,
      where:
        f.branch_id == ^id and f.active and is_nil(f.used_at) and
          f.subscription_feature_slug == "bid_proposal" and
          f.begin_at <= ^time and f.expire_at > ^time
    )
    |> Repo.all()
  end

  @doc """
  Creates a available_subscription_feature.

  ## Examples

      iex> create_available_subscription_feature(%{field: value})
      {:ok, %AvailableSubscriptionFeature{}}

      iex> create_available_subscription_feature(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_available_subscription_feature(attrs \\ %{}) do
    %AvailableSubscriptionFeature{}
    |> AvailableSubscriptionFeature.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a available_subscription_feature.

  ## Examples

      iex> update_available_subscription_feature(available_subscription_feature, %{field: new_value})
      {:ok, %AvailableSubscriptionFeature{}}

      iex> update_available_subscription_feature(available_subscription_feature, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_available_subscription_feature(
        %AvailableSubscriptionFeature{} = available_subscription_feature,
        attrs
      ) do
    available_subscription_feature
    |> AvailableSubscriptionFeature.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a available_subscription_feature.

  ## Examples

      iex> delete_available_subscription_feature(available_subscription_feature)
      {:ok, %AvailableSubscriptionFeature{}}

      iex> delete_available_subscription_feature(available_subscription_feature)
      {:error, %Ecto.Changeset{}}

  """
  def delete_available_subscription_feature(
        %AvailableSubscriptionFeature{} = available_subscription_feature
      ) do
    Repo.delete(available_subscription_feature)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking available_subscription_feature changes.

  ## Examples

      iex> change_available_subscription_feature(available_subscription_feature)
      %Ecto.Changeset{source: %AvailableSubscriptionFeature{}}

  """
  def change_available_subscription_feature(
        %AvailableSubscriptionFeature{} = available_subscription_feature
      ) do
    AvailableSubscriptionFeature.changeset(available_subscription_feature, %{})
  end
end
