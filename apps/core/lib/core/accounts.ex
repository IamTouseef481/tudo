defmodule Core.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Schemas.{Session, User, UserAddress, UserInstalls, UserStatuses}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    #    pagination_params = CoreWeb.Utils.Paginator.make_pagination_params()
    #    User
    #    |> Scrivener.Paginater.paginate(pagination_params)
    Repo.all(User)
  end

  def list_users_and_related_installs do
    User
    |> Repo.all()
    |> Repo.preload([:user_installs])
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get(User, id)

  def get_user_short_object(id) do
    user =
      User
      |> where([u], u.id == ^id)
      |> select([u], %{id: u.id, profile: u.profile})
      |> Repo.one()

    %{
      id: to_string(user.id),
      first_name: user.profile["first_name"],
      last_name: user.profile["last_name"],
      profile: user.profile
    }
  end

  def get_user_small_object(id) do
    user =
      User
      |> where([u], u.id == ^id)
      |> select([u], %{id: u.id, profile: u.profile})
      |> Repo.one()

    %{
      id: user.id,
      first_name: user.profile["first_name"],
      last_name: user.profile["last_name"],
      profile: user.profile["profile_image"]
    }
  end

  def get_user_short_object_for_socket(id) do
    User
    |> where([u], u.id == ^id)
    |> select([u], %{user_id: u.id, profile: u.profile})
    |> Repo.one()
    |> CoreWeb.Utils.CommonFunctions.snake_keys_to_camel()
  end

  def get_user_short_object_for_call_meta(id) do
    User
    |> where([u], u.id == ^id)
    |> select([u], %{id: u.id, profile: u.profile})
    |> Repo.one()
  end

  def get_user_referral_code(id) do
    from(u in User,
      where: u.id == ^id,
      select: u.referral_code
    )
    |> Repo.one()
  end

  def get_user_by_email(email), do: User |> Repo.get_by(%{email: String.downcase(email)})

  def get_user_by_referral_code(referral_code),
    do: User |> Repo.get_by(%{referral_code: referral_code})

  def get_user_by_employee_id(employee_id) do
    from(u in User,
      join: e in Core.Schemas.Employee,
      on: e.user_id == u.id,
      where: e.id == ^employee_id
    )
    |> Repo.one()
  end

  def get_public_user_by_email(email) do
    from(u in User,
      where: u.email == ^String.downcase(email),
      where: u.profile_public,
      where: u.status_id == "confirmed"
    )
    |> Repo.one()
  end

  def get_public_user_by_mobile(mobile) do
    from(u in User,
      where: fragment("? ilike ?", u.mobile, ^"%#{mobile}%"),
      where: u.profile_public,
      where: u.status_id == "confirmed",
      distinct: u.id
    )
    |> Repo.all()
  end

  def search_person_by_first_or_last_name(name) do
    from(u in User,
      where:
        (fragment("? ->> ? ilike ?", u.profile, "first_name", ^"%#{name}%") or
           fragment("? ->> ? ilike ?", u.profile, "last_name", ^"%#{name}%")) and u.profile_public,
      where: u.status_id == "confirmed",
      distinct: u.id
    )
    |> Repo.all()
  end

  def search_person_by_first_and_last_name(first_name, last_name) do
    from(u in User,
      where:
        fragment("? ->> ? ilike ?", u.profile, "first_name", ^"%#{first_name}%") and
          fragment("? ->> ? ilike ?", u.profile, "last_name", ^"%#{last_name}%") and
          u.profile_public,
      distinct: u.id
    )
    |> Repo.all()
  end

  def get_bsp_user(user_id) do
    from(u in User, where: u.id == ^user_id and u.is_bsp == true)
    |> Repo.one()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_for_invite(attrs \\ %{}) do
    %User{}
    |> User.invite_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_password(user, attrs) do
    user
    |> User.forget_changeset(attrs)
    |> Repo.update()
  end

  def check_user_role(user_id) do
    User
    |> where([u], u.id == ^user_id)
    |> select([u], u.acl_role_id)
    |> Repo.one()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def authenticate(args) do
    user = User |> Repo.get_by(email: String.downcase(args.email))

    case user do
      nil ->
        {:not_exist, ["Account user id and/ or password incorrect, check your entry"]}

      %{status_id: "registration_pending"} ->
        {:error, Map.merge(user, %{meta: %{message: "Redirect to register screen"}})}

      %{status_id: "blocked"} ->
        {:not_exist, ["You are blocked"]}

      _ ->
        check_password(user, args)
    end
  end

  defp check_password(user, args) do
    case Argon2.verify_pass(args.password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:not_exist, ["Invalid email or password"]}
    end
  end

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{source: %Session{}}

  """
  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end

  @doc """
  Returns the list of user_installs.

  ## Examples

      iex> list_user_installs()
      [%UserInstalls{}, ...]

  """
  def list_user_installs do
    Repo.all(UserInstalls)
  end

  @doc """
  Gets a single user_installs.

  Raises `Ecto.NoResultsError` if the User installs does not exist.

  ## Examples

      iex> get_user_installs!(123)
      %UserInstalls{}

      iex> get_user_installs!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_installs!(id), do: Repo.get!(UserInstalls, id)

  def get_user_installs_by_device_token(token),
    do: Repo.get_by(UserInstalls, %{device_token: token})

  def get_user_installs_by_user_id(id),
    do: Repo.get_by(UserInstalls, %{user_id: id})

  def get_user_installs_by_user(id) do
    Repo.all(from ui in UserInstalls, where: ui.user_id == ^id)
  end

  def get_user_installs_by_user_and_fcm_token(user_id, fcm_token) do
    Repo.all(
      from u in UserInstalls,
        where: u.user_id == ^user_id and u.fcm_token == ^fcm_token
    )
  end

  def get_list_of_fcm_token(user_id) do
    UserInstalls
    |> where([us], us.user_id == ^user_id)
    |> select([us], us.fcm_token)
    |> Repo.all()
  end

  def get_user_installs_by_user_and_device_token(user_id, device_token) do
    Repo.one(
      from u in UserInstalls,
        where: u.user_id == ^user_id and u.device_token == ^device_token
    )
  end

  @doc """
  Creates a user_installs.

  ## Examples

      iex> create_user_installs(%{field: value})
      {:ok, %UserInstalls{}}

      iex> create_user_installs(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_installs(attrs \\ %{}) do
    %UserInstalls{}
    |> UserInstalls.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_installs.

  ## Examples

      iex> update_user_installs(user_installs, %{field: new_value})
      {:ok, %UserInstalls{}}

      iex> update_user_installs(user_installs, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_installs(%UserInstalls{} = user_installs, attrs) do
    user_installs
    |> UserInstalls.changeset(attrs)
    |> Repo.update()
  end

  def update_user_installs_fcm_token(%UserInstalls{} = user_installs, attrs) do
    user_installs
    |> UserInstalls.changeset_for_update_fcm_token(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserInstalls.

  ## Examples

      iex> delete_user_installs(user_installs)
      {:ok, %UserInstalls{}}

      iex> delete_user_installs(user_installs)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_installs(%UserInstalls{} = user_installs) do
    Repo.delete(user_installs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_installs changes.

  ## Examples

      iex> change_user_installs(user_installs)
      %Ecto.Changeset{source: %UserInstalls{}}

  """
  def change_user_installs(%UserInstalls{} = user_installs) do
    UserInstalls.changeset(user_installs, %{})
  end

  @doc """
  Returns the list of user_statuses.

  ## Examples

      iex> list_user_statuses()
      [%UserStatus{}, ...]

  """
  def list_user_statuses do
    Repo.all(UserStatuses)
  end

  @doc """
  Gets a single user_status.

  Raises `Ecto.NoResultsError` if the User status does not exist.

  ## Examples

      iex> get_user_status!(123)
      %UserStatus{}

      iex> get_user_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_status!(id), do: Repo.get!(UserStatuses, id)
  def get_user_status(id), do: Repo.get(UserStatuses, id)

  @doc """
  Creates a user_status.

  ## Examples

      iex> create_user_status(%{field: value})
      {:ok, %UserStatus{}}

      iex> create_user_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_status(attrs \\ %{}) do
    %UserStatuses{}
    |> UserStatuses.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_status.

  ## Examples

      iex> update_user_status(user_status, %{field: new_value})
      {:ok, %UserStatus{}}

      iex> update_user_status(user_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_status(%UserStatuses{} = user_status, attrs) do
    user_status
    |> UserStatuses.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserStatus.

  ## Examples

      iex> delete_user_status(user_status)
      {:ok, %UserStatus{}}

      iex> delete_user_status(user_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_status(%UserStatuses{} = user_status) do
    Repo.delete(user_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_status changes.

  ## Examples

      iex> change_user_status(user_status)
      %Ecto.Changeset{source: %UserStatus{}}

  """
  def change_user_status(%UserStatuses{} = user_status) do
    UserStatuses.changeset(user_status, %{})
  end

  @doc """
  Returns the list of user_addresses.

  ## Examples

      iex> list_user_addresses()
      [%UserAddress{}, ...]

  """
  def list_user_addresses do
    Repo.all(UserAddress)
  end

  @doc """
  Gets a single user_address.

  Raises `Ecto.NoResultsError` if the User address does not exist.

  ## Examples

      iex> get_user_address!(123)
      %UserAddress{}

      iex> get_user_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_address(id), do: Repo.get(UserAddress, id)

  def get_user_address_by(user_id) do
    Repo.all(from ua in UserAddress, where: ua.user_id == ^user_id)
  end

  @doc """
  Creates a user_address.

  ## Examples

      iex> create_user_address(%{field: value})
      {:ok, %UserAddress{}}

      iex> create_user_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_address(attrs \\ %{}) do
    %UserAddress{}
    |> UserAddress.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_address.

  ## Examples

      iex> update_user_address(user_address, %{field: new_value})
      {:ok, %UserAddress{}}

      iex> update_user_address(user_address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_address(%UserAddress{} = user_address, attrs) do
    user_address
    |> UserAddress.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserAddress.

  ## Examples

      iex> delete_user_address(user_address)
      {:ok, %UserAddress{}}

      iex> delete_user_address(user_address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_address(%UserAddress{} = user_address) do
    Repo.delete(user_address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_address changes.

  ## Examples

      iex> change_user_address(user_address)
      %Ecto.Changeset{source: %UserAddress{}}

  """
  def change_user_address(%UserAddress{} = user_address) do
    UserAddress.changeset(user_address, %{})
  end

  def get_leads_by_city_for_marketing_group(branch_location) do
    from(add in UserAddress,
      where:
        fragment(
          "calculate_distance_for_marketing_group(?,?,?)",
          add.geo_location,
          ^branch_location,
          150
        ),
      distinct: add.user_id,
      select: add.user_id
    )
    |> Repo.all()
  end
end
