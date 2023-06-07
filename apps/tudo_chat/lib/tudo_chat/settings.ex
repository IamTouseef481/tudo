defmodule TudoChat.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  alias TudoChat.Repo

  alias TudoChat.Settings.{GroupSetting, Setting}

  @doc """
  Returns the list of settings.

  ## Examples

      iex> list_settings()
      [%Setting{}, ...]

  """
  def list_settings do
    Repo.all(Setting)
  end

  @doc """
  Gets a single setting.

  Raises `Ecto.NoResultsError` if the Setting does not exist.

  ## Examples

      iex> get_setting!(123)
      %Setting{}

      iex> get_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_setting!(id), do: Repo.get!(Setting, id)
  def get_setting(id), do: Repo.get(Setting, id)

  def settings_by_type(%{user_id: user_id, type: type}) do
    from(s in Setting, where: s.user_id == ^user_id and s.type == ^type)
    |> Repo.all()
  end

  def settings_by_slug(%{user_id: user_id, slug: slug}) do
    from(s in Setting, where: s.user_id == ^user_id and s.slug == ^slug)
    |> Repo.all()
  end

  @doc """
  Creates a setting.

  ## Examples

      iex> create_setting(%{field: value})
      {:ok, %Setting{}}

      iex> create_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_setting(attrs \\ %{}) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a setting.

  ## Examples

      iex> update_setting(setting, %{field: new_value})
      {:ok, %Setting{}}

      iex> update_setting(setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_setting(%Setting{} = setting, attrs) do
    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a setting.

  ## Examples

      iex> delete_setting(setting)
      {:ok, %Setting{}}

      iex> delete_setting(setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_setting(%Setting{} = setting) do
    Repo.delete(setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking setting changes.

  ## Examples

      iex> change_setting(setting)
      %Ecto.Changeset{source: %Setting{}}

  """
  def change_setting(%Setting{} = setting) do
    Setting.changeset(setting, %{})
  end

  @doc """
  Returns the list of group_settings.

  ## Examples

      iex> list_group_settings()
      [%GroupSetting{}, ...]

  """
  def list_group_settings do
    Repo.all(GroupSetting)
  end

  @doc """
  Gets a single group_setting.

  Raises `Ecto.NoResultsError` if the Group setting does not exist.

  ## Examples

      iex> get_group_setting!(123)
      %GroupSetting{}

      iex> get_group_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_setting!(id), do: Repo.get!(GroupSetting, id)
  def get_group_setting(id), do: Repo.get(GroupSetting, id)

  def group_settings(%{user_id: user_id, group_id: group_id}) do
    from(s in GroupSetting, where: s.user_id == ^user_id and s.group_id == ^group_id)
    |> Repo.all()
  end

  def group_settings_by_slug(%{user_id: user_id, group_id: group_id, slug: slug}) do
    from(s in GroupSetting,
      where: s.user_id == ^user_id and s.slug == ^slug and s.group_id == ^group_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a group_setting.

  ## Examples

      iex> create_group_setting(%{field: value})
      {:ok, %GroupSetting{}}

      iex> create_group_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_setting(attrs \\ %{}) do
    %GroupSetting{}
    |> GroupSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_setting.

  ## Examples

      iex> update_group_setting(group_setting, %{field: new_value})
      {:ok, %GroupSetting{}}

      iex> update_group_setting(group_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_setting(%GroupSetting{} = group_setting, attrs) do
    group_setting
    |> GroupSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_setting.

  ## Examples

      iex> delete_group_setting(group_setting)
      {:ok, %GroupSetting{}}

      iex> delete_group_setting(group_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_setting(%GroupSetting{} = group_setting) do
    Repo.delete(group_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_setting changes.

  ## Examples

      iex> change_group_setting(group_setting)
      %Ecto.Changeset{source: %GroupSetting{}}

  """
  def change_group_setting(%GroupSetting{} = group_setting) do
    GroupSetting.changeset(group_setting, %{})
  end
end
