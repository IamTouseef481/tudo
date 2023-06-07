defmodule Core.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{AdminNotificationSetting, PushNotification}

  @doc """
  Returns the list of push_notifications.

  ## Examples

      iex> list_push_notifications()
      [%PushNotification{}, ...]

  """
  def list_push_notifications do
    Repo.all(PushNotification)
  end

  @doc """
  Gets a single push_notification.

  Raises `Ecto.NoResultsError` if the Push notification does not exist.

  ## Examples

      iex> get_push_notification!(123)
      %PushNotification{}

      iex> get_push_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_push_notification!(id), do: Repo.get!(PushNotification, id)
  def get_push_notification(id), do: Repo.get(PushNotification, id)

  def get_unread_push_notification(id) do
    from(n in PushNotification, where: n.id == ^id and not n.read)
    |> Repo.one()
  end

  def get_push_notifications_by_user_role(%{
        acl_role_id: role,
        user_id: user_id,
        read: false,
        branch_id: branch_id
      }) do
    from(n in PushNotification,
      where:
        n.user_id == ^user_id and n.acl_role_id == ^role and n.read == false and
          n.branch_id == ^branch_id,
      order_by: [desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_push_notifications_by_user_role(%{
        acl_role_id: role,
        user_id: user_id,
        read: true,
        branch_id: branch_id
      }) do
    from(n in PushNotification,
      where:
        n.user_id == ^user_id and n.acl_role_id == ^role and n.read and n.branch_id == ^branch_id,
      order_by: [desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_push_notifications_by_user_role(%{
        acl_role_id: role,
        user_id: user_id,
        branch_id: branch_id
      }) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role and n.branch_id == ^branch_id,
      order_by: [n.read, desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_push_notifications_by_user_role(%{acl_role_id: role, user_id: user_id, read: false}) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role and n.read == false,
      order_by: [desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_push_notifications_by_user_role(%{acl_role_id: role, user_id: user_id, read: true}) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role and n.read,
      order_by: [desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_push_notifications_by_user_role(%{acl_role_id: role, user_id: user_id}) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role,
      order_by: [n.read, desc: n.pushed_at]
    )
    |> Repo.all()
  end

  def get_unread_push_notifications_count_by_user_role(user_id, role) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role and n.read == false,
      select: count(n.id)
    )
    |> Repo.one()
  end

  def get_trashable_push_notifications(user_id, role) do
    from(n in PushNotification,
      where: n.user_id == ^user_id and n.acl_role_id == ^role,
      order_by: [n.read, desc: n.pushed_at],
      offset: 50
    )
    |> Repo.all()
  end

  @doc """
  Creates a push_notification.

  ## Examples

      iex> create_push_notification(%{field: value})
      {:ok, %PushNotification{}}

      iex> create_push_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_push_notification(attrs \\ %{}) do
    %PushNotification{}
    |> PushNotification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a push_notification.

  ## Examples

      iex> update_push_notification(push_notification, %{field: new_value})
      {:ok, %PushNotification{}}

      iex> update_push_notification(push_notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_push_notification(%PushNotification{} = push_notification, attrs) do
    push_notification
    |> PushNotification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a push_notification.

  ## Examples

      iex> delete_push_notification(push_notification)
      {:ok, %PushNotification{}}

      iex> delete_push_notification(push_notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_push_notification(%PushNotification{} = push_notification) do
    Repo.delete(push_notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking push_notification changes.

  ## Examples

      iex> change_push_notification(push_notification)
      %Ecto.Changeset{source: %PushNotification{}}

  """
  def change_push_notification(%PushNotification{} = push_notification) do
    PushNotification.changeset(push_notification, %{})
  end

  @doc """
  Returns the list of admin_notification_settings.

  ## Examples

      iex> list_admin_notification_settings()
      [%AdminNotificationSetting{}, ...]

  """
  def list_admin_notification_settings do
    Repo.all(AdminNotificationSetting)
  end

  @doc """
  Gets a single admin_notification_setting.

  Raises `Ecto.NoResultsError` if the Admin notification setting does not exist.

  ## Examples

      iex> get_admin_notification_setting!(123)
      %AdminNotificationSetting{}

      iex> get_admin_notification_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_admin_notification_setting!(id), do: Repo.get!(AdminNotificationSetting, id)
  def get_admin_notification_setting(id), do: Repo.get(AdminNotificationSetting, id)

  def get_admin_notification_setting_for_bsp(slug) do
    from(s in AdminNotificationSetting,
      where: s.slug == ^slug,
      select: s.bsp_notification
    )
    |> Repo.one()
  end

  def get_admin_notification_setting_for_cmr(slug) do
    from(s in AdminNotificationSetting,
      where: s.slug == ^slug,
      select: s.cmr_notification
    )
    |> Repo.one()
  end

  def get_admin_email_setting_for_bsp(slug) do
    from(s in AdminNotificationSetting,
      where: s.slug == ^slug,
      select: s.bsp_email
    )
    |> Repo.one()
  end

  def get_admin_email_setting_for_cmr(slug) do
    from(s in AdminNotificationSetting,
      where: s.slug == ^slug,
      select: s.cmr_email
    )
    |> Repo.one()
  end

  @doc """
  Creates a admin_notification_setting.

  ## Examples

      iex> create_admin_notification_setting(%{field: value})
      {:ok, %AdminNotificationSetting{}}

      iex> create_admin_notification_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_admin_notification_setting(attrs \\ %{}) do
    %AdminNotificationSetting{}
    |> AdminNotificationSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a admin_notification_setting.

  ## Examples

      iex> update_admin_notification_setting(admin_notification_setting, %{field: new_value})
      {:ok, %AdminNotificationSetting{}}

      iex> update_admin_notification_setting(admin_notification_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin_notification_setting(
        %AdminNotificationSetting{} = admin_notification_setting,
        attrs
      ) do
    admin_notification_setting
    |> AdminNotificationSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a admin_notification_setting.

  ## Examples

      iex> delete_admin_notification_setting(admin_notification_setting)
      {:ok, %AdminNotificationSetting{}}

      iex> delete_admin_notification_setting(admin_notification_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_admin_notification_setting(%AdminNotificationSetting{} = admin_notification_setting) do
    Repo.delete(admin_notification_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin_notification_setting changes.

  ## Examples

      iex> change_admin_notification_setting(admin_notification_setting)
      %Ecto.Changeset{source: %AdminNotificationSetting{}}

  """
  def change_admin_notification_setting(%AdminNotificationSetting{} = admin_notification_setting) do
    AdminNotificationSetting.changeset(admin_notification_setting, %{})
  end
end
