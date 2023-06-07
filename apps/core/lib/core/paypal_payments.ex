defmodule Core.PaypalPayments do
  @moduledoc """
  The PaypalPayments context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    Branch,
    BranchService,
    Business,
    Job,
    PaypalAccessAttributes,
    PaypalSeller,
    PaypalSubscription,
    PaypalSubscriptionPlan
  }

  @doc """
  Returns the list of paypal_sellers.

  ## Examples

      iex> list_paypal_sellers()
      [%PaypalSeller{}, ...]

  """
  def list_paypal_sellers do
    Repo.all(PaypalSeller)
  end

  @doc """
  Gets a single paypal_seller.

  Raises `Ecto.NoResultsError` if the Paypal seller does not exist.

  ## Examples

      iex> get_paypal_seller!(123)
      %PaypalSeller{}

      iex> get_paypal_seller!(456)
      ** (Ecto.NoResultsError)

  """
  def get_paypal_seller!(id), do: Repo.get!(PaypalSeller, id)
  def get_paypal_seller(id), do: Repo.get(PaypalSeller, id)

  def get_paypal_seller_by_user(user_id) do
    from(s in PaypalSeller, where: s.user_id == ^user_id, limit: 1, order_by: [desc: s.id])
    |> Repo.one()
  end

  def get_default_paypal_seller_account_by_user(user_id) do
    from(s in PaypalSeller,
      where: s.user_id == ^user_id and s.default,
      limit: 1,
      order_by: [desc: s.id]
    )
    |> Repo.one()
  end

  def get_paypal_seller_accounts_by_user(user_id) do
    from(s in PaypalSeller, where: s.user_id == ^user_id)
    |> Repo.all()
  end

  def get_paypal_seller_by(%{user_id: user_id, id: seller_id}) do
    from(s in PaypalSeller,
      where: s.user_id == ^user_id and s.id == ^seller_id,
      limit: 1,
      order_by: [desc: s.id]
    )
    |> Repo.one()
  end

  def get_paypal_seller_by_job_id(job_id) do
    from(j in Job,
      join: bs in BranchService,
      on: j.branch_service_id == bs.id,
      join: b in Branch,
      on: bs.branch_id == b.id,
      join: bus in Business,
      on: b.business_id == bus.id,
      join: s in PaypalSeller,
      on: s.user_id == bus.user_id,
      where: j.id == ^job_id,
      limit: 1,
      order_by: [desc: s.id],
      select: s.email
    )
    |> Repo.one()
  end

  @doc """
  Creates a paypal_seller.

  ## Examples

      iex> create_paypal_seller(%{field: value})
      {:ok, %PaypalSeller{}}

      iex> create_paypal_seller(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_paypal_seller(attrs \\ %{}) do
    %PaypalSeller{}
    |> PaypalSeller.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a paypal_seller.

  ## Examples

      iex> update_paypal_seller(paypal_seller, %{field: new_value})
      {:ok, %PaypalSeller{}}

      iex> update_paypal_seller(paypal_seller, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_paypal_seller(%PaypalSeller{} = paypal_seller, attrs) do
    paypal_seller
    |> PaypalSeller.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a paypal_seller.

  ## Examples

      iex> delete_paypal_seller(paypal_seller)
      {:ok, %PaypalSeller{}}

      iex> delete_paypal_seller(paypal_seller)
      {:error, %Ecto.Changeset{}}

  """
  def delete_paypal_seller(%PaypalSeller{} = paypal_seller) do
    Repo.delete(paypal_seller)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking paypal_seller changes.

  ## Examples

      iex> change_paypal_seller(paypal_seller)
      %Ecto.Changeset{source: %PaypalSeller{}}

  """
  def change_paypal_seller(%PaypalSeller{} = paypal_seller) do
    PaypalSeller.changeset(paypal_seller, %{})
  end

  @doc """
  Returns the list of paypal_subscriptions.

  ## Examples

      iex> list_paypal_subscriptions()
      [%PaypalSubscription{}, ...]

  """
  def list_paypal_subscriptions do
    Repo.all(PaypalSubscription)
  end

  @doc """
  Gets a single paypal_subscription.

  Raises `Ecto.NoResultsError` if the Paypal subscription does not exist.

  ## Examples

      iex> get_paypal_subscription!(123)
      %PaypalSubscription{}

      iex> get_paypal_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_paypal_subscription!(id), do: Repo.get!(PaypalSubscription, id)
  def get_paypal_subscription(id), do: Repo.get(PaypalSubscription, id)

  def get_paypal_subscription_by_business(id) do
    from(s in PaypalSubscription,
      where: s.business_id == ^id and s.status_id == "active",
      order_by: [desc: :inserted_at]
    )
    |> Repo.all()
  end

  @doc """
      check_user_subscriptions_exist?/3
      # This one is used as a resolver function, called from a schema object directly.
      # It checks if a user has a subscription other than the freelancer one.
      # Returns true if a user has a paid subscription, false otherwise
  """
  def check_user_subscriptions_exist?(_, %{input: %{user_id: user_id}}, _) do
    data =
      PaypalSubscription
      |> where([sub], sub.user_id == ^user_id and sub.slug != "freelancer")
      |> Repo.all()

    {:ok, data}
  end

  def get_paypal_subscription_by_name(name) do
    from(s in PaypalSubscriptionPlan,
      where: s.name == ^name
    )
    |> Repo.one()
  end

  def get_paypal_subscription_by_branch(id) do
    from(
      s in PaypalSubscription,
      join: b in Core.Schemas.Branch,
      on: b.business_id == s.business_id,
      where: b.id == ^id and s.status_id == "active",
      order_by: [desc: :inserted_at],
      distinct: s.id
    )
    |> Repo.all()
  end

  def get_paypal_business_subscription_for_activation(id) do
    from(s in PaypalSubscription,
      where: s.business_id == ^id,
      order_by: [desc: :inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a paypal_subscription.

  ## Examples

      iex> create_paypal_subscription(%{field: value})
      {:ok, %PaypalSubscription{}}

      iex> create_paypal_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_paypal_subscription(attrs \\ %{}) do
    %PaypalSubscription{}
    |> PaypalSubscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a paypal_subscription.

  ## Examples

      iex> update_paypal_subscription(paypal_subscription, %{field: new_value})
      {:ok, %PaypalSubscription{}}

      iex> update_paypal_subscription(paypal_subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_paypal_subscription(%PaypalSubscription{} = paypal_subscription, attrs) do
    paypal_subscription
    |> PaypalSubscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a paypal_subscription.

  ## Examples

      iex> delete_paypal_subscription(paypal_subscription)
      {:ok, %PaypalSubscription{}}

      iex> delete_paypal_subscription(paypal_subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_paypal_subscription(%PaypalSubscription{} = paypal_subscription) do
    Repo.delete(paypal_subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking paypal_subscription changes.

  ## Examples

      iex> change_paypal_subscription(paypal_subscription)
      %Ecto.Changeset{source: %PaypalSubscription{}}

  """
  def change_paypal_subscription(%PaypalSubscription{} = paypal_subscription) do
    PaypalSubscription.changeset(paypal_subscription, %{})
  end

  @doc """
  Returns the list of paypal_subscription_plans.

  ## Examples

      iex> list_paypal_subscription_plans()
      [%PaypalSubscriptionPlan{}, ...]

  """
  def list_paypal_subscription_plans do
    Repo.all(PaypalSubscriptionPlan)
  end

  @doc """
  Gets a single paypal_subscription_plan.

  Raises `Ecto.NoResultsError` if the Paypal subscription plan does not exist.

  ## Examples

      iex> get_paypal_subscription_plan!(123)
      %PaypalSubscriptionPlan{}

      iex> get_paypal_subscription_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_paypal_subscription_plan!(id), do: Repo.get!(PaypalSubscriptionPlan, id)
  def get_paypal_subscription_plan(id), do: Repo.get(PaypalSubscriptionPlan, id)

  def get_subscription_plan_by_cashfree_plan_id(plan_id),
    do: Repo.get_by(PaypalSubscriptionPlan, cashfree_plan_id: plan_id)

  def get_paypal_subscription_plans_by(%{country_id: country_id, type: type}) do
    from(p in PaypalSubscriptionPlan,
      where: (p.country_id == ^country_id or p.country_id == 1) and p.active and p.type == ^type
    )
    |> Repo.all()
  end

  def get_paypal_subscription_plans_by(%{country_id: country_id}) do
    from(p in PaypalSubscriptionPlan,
      where: (p.country_id == ^country_id or p.country_id == 1) and p.active
    )
    |> Repo.all()
  end

  def get_paypal_subscription_plan_by_country(plan_id, country_id) do
    from(p in PaypalSubscriptionPlan,
      where: (p.country_id == ^country_id or p.country_id == 1) and p.active and p.id == ^plan_id
    )
    |> Repo.one()
  end

  def get_cashfree_plan_by_country(plan_id, country_id) do
    from(p in PaypalSubscriptionPlan,
      where:
        (p.country_id == ^country_id or p.country_id == 1) and p.active and
          p.cashfree_plan_id == ^plan_id
    )
    |> Repo.one()
  end

  def get_paypal_subscription_plan_by_country_and_slug(slug, country_id) do
    from(p in PaypalSubscriptionPlan,
      where: (p.country_id == ^country_id or p.country_id == 1) and p.active and p.slug == ^slug,
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a paypal_subscription_plan.

  ## Examples

      iex> create_paypal_subscription_plan(%{field: value})
      {:ok, %PaypalSubscriptionPlan{}}

      iex> create_paypal_subscription_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_paypal_subscription_plan(attrs \\ %{}) do
    %PaypalSubscriptionPlan{}
    |> PaypalSubscriptionPlan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a paypal_subscription_plan.

  ## Examples

      iex> update_paypal_subscription_plan(paypal_subscription_plan, %{field: new_value})
      {:ok, %PaypalSubscriptionPlan{}}

      iex> update_paypal_subscription_plan(paypal_subscription_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_paypal_subscription_plan(%PaypalSubscriptionPlan{} = paypal_subscription_plan, attrs) do
    paypal_subscription_plan
    |> PaypalSubscriptionPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a paypal_subscription_plan.

  ## Examples

      iex> delete_paypal_subscription_plan(paypal_subscription_plan)
      {:ok, %PaypalSubscriptionPlan{}}

      iex> delete_paypal_subscription_plan(paypal_subscription_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_paypal_subscription_plan(%PaypalSubscriptionPlan{} = paypal_subscription_plan) do
    Repo.delete(paypal_subscription_plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking paypal_subscription_plan changes.

  ## Examples

      iex> change_paypal_subscription_plan(paypal_subscription_plan)
      %Ecto.Changeset{source: %PaypalSubscriptionPlan{}}

  """
  def change_paypal_subscription_plan(%PaypalSubscriptionPlan{} = paypal_subscription_plan) do
    PaypalSubscriptionPlan.changeset(paypal_subscription_plan, %{})
  end

  @doc """
  Returns the list of paypal_access_attributes.

  ## Examples

      iex> list_paypal_access_attributes()
      [%PaypalAccessAttributes{}, ...]

  """
  def list_paypal_access_attributes do
    Repo.all(PaypalAccessAttributes)
  end

  @doc """
  Gets a single paypal_access_attributes.

  Raises `Ecto.NoResultsError` if the Paypal access attributes does not exist.

  ## Examples

      iex> get_paypal_access_attributes!(123)
      %PaypalAccessAttributes{}

      iex> get_paypal_access_attributes!(456)
      ** (Ecto.NoResultsError)

  """
  def get_paypal_access_attributes!(id), do: Repo.get!(PaypalAccessAttributes, id)

  def get_paypal_access_token do
    from(attr in PaypalAccessAttributes,
      where: not is_nil(attr.access_token),
      limit: 1,
      order_by: [desc: attr.id]
    )
    |> Repo.one()
  end

  def get_paypal_access_token_for_update do
    from(attr in PaypalAccessAttributes,
      limit: 1,
      order_by: [desc: attr.id]
    )
    |> Repo.one()
  end

  @doc """
  Creates a paypal_access_attributes.

  ## Examples

      iex> create_paypal_access_attributes(%{field: value})
      {:ok, %PaypalAccessAttributes{}}

      iex> create_paypal_access_attributes(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_paypal_access_attributes(attrs \\ %{}) do
    %PaypalAccessAttributes{}
    |> PaypalAccessAttributes.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a paypal_access_attributes.

  ## Examples

      iex> update_paypal_access_attributes(paypal_access_attributes, %{field: new_value})
      {:ok, %PaypalAccessAttributes{}}

      iex> update_paypal_access_attributes(paypal_access_attributes, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_paypal_access_attributes(%PaypalAccessAttributes{} = paypal_access_attributes, attrs) do
    paypal_access_attributes
    |> PaypalAccessAttributes.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a paypal_access_attributes.

  ## Examples

      iex> delete_paypal_access_attributes(paypal_access_attributes)
      {:ok, %PaypalAccessAttributes{}}

      iex> delete_paypal_access_attributes(paypal_access_attributes)
      {:error, %Ecto.Changeset{}}

  """
  def delete_paypal_access_attributes(%PaypalAccessAttributes{} = paypal_access_attributes) do
    Repo.delete(paypal_access_attributes)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking paypal_access_attributes changes.

  ## Examples

      iex> change_paypal_access_attributes(paypal_access_attributes)
      %Ecto.Changeset{source: %PaypalAccessAttributes{}}

  """
  def change_paypal_access_attributes(%PaypalAccessAttributes{} = paypal_access_attributes) do
    PaypalAccessAttributes.changeset(paypal_access_attributes, %{})
  end
end
