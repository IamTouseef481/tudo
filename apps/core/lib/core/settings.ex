defmodule Core.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Schemas.{Branch, BSPSetting, CMRSetting, Employee, Setting, TudoSetting}

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

  def settings_by_type(%{type: type, branch_id: branch_id}) do
    from(s in Setting, where: s.type == ^type and s.branch_id == ^branch_id)
    |> Repo.all()
  end

  def get_settings_by(%{type: type, branch_id: branch_id, slug: slug}) do
    from(s in Setting,
      where: s.type == ^type and s.branch_id == ^branch_id and s.slug in ^slug
    )
    |> Repo.all()
  end

  def get_settings_by(%{branch_id: branch_id, slug: slug}) do
    from(s in Setting,
      where: s.branch_id == ^branch_id and s.slug == ^slug
    )
    |> Repo.one()
  end

  def get_settings_by_employee_id(employee_id) do
    Repo.one(
      from st in Setting,
        left_join: e in Employee,
        on: e.id == ^employee_id,
        left_join: b in Branch,
        on: b.id == e.branch_id,
        where: st.slug == ^"availability" and b.id == st.branch_id
    )
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
  Deletes a Setting.

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
  Returns the list of cmr_settings.

  ## Examples

      iex> list_cmr_settings()
      [%CMRSetting{}, ...]

  """
  def list_cmr_settings do
    Repo.all(CMRSetting)
  end

  @doc """
  Gets a single cmr_settings.

  Raises `Ecto.NoResultsError` if the CMR Settings does not exist.

  ## Examples

      iex> get_cmr_settings!(123)
      %CMRSetting{}

      iex> get_cmr_settings!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cmr_settings!(id), do: Repo.get!(CMRSetting, id)
  def get_cmr_settings(id), do: Repo.get(CMRSetting, id)

  def get_cmr_settings_by_user(setting_id, user_id) do
    from(s in CMRSetting, where: s.user_id == ^user_id and s.id == ^setting_id)
    |> Repo.one()
  end

  def get_cmr_settings_by_employee(%{slug: slug, employee_id: employee_id}) do
    from(s in CMRSetting, where: s.slug == ^slug and s.employee_id == ^employee_id)
    |> Repo.all()
  end

  def get_cmr_settings_by_slug_and_user(%{user_id: user_id, slug: slug}) do
    from(s in CMRSetting, where: s.user_id == ^user_id and s.slug == ^slug)
    |> Repo.all()
  end

  def get_cmr_settings_by(%{employee_id: employee_id}) do
    from(s in CMRSetting, where: s.employee_id == ^employee_id)
    |> Repo.all()
  end

  def get_cmr_settings_by(%{user_id: user_id}) do
    from(s in CMRSetting,
      where: s.user_id == ^user_id and (s.type != "preference" or is_nil(s.type))
    )
    |> Repo.all()
  end

  def get_cmr_settings_by_user_id(%{user_id: user_id}) do
    from(s in CMRSetting,
      where: s.user_id == ^user_id
    )
    |> Repo.all()
  end

  def get_cmr_preference_settings(user_id) do
    from(s in CMRSetting, where: s.user_id == ^user_id and s.type == "preference")
    |> Repo.all()
  end

  @doc """
  Creates a cmr_settings.

  ## Examples

      iex> create_cmr_settings(%{field: value})
      {:ok, %CMRSetting{}}

      iex> create_cmr_settings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cmr_settings(attrs \\ %{}) do
    %CMRSetting{}
    |> CMRSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cmr_settings.

  ## Examples

      iex> update_cmr_settings(cmr_settings, %{field: new_value})
      {:ok, %CMRSetting{}}

      iex> update_cmr_settings(cmr_settings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cmr_settings(%CMRSetting{} = cmr_settings, attrs) do
    cmr_settings
    |> CMRSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cmr_settings.

  ## Examples

      iex> delete_cmr_settings(cmr_settings)
      {:ok, %CMRSetting{}}

      iex> delete_cmr_settings(cmr_settings)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cmr_settings(%CMRSetting{} = cmr_settings) do
    Repo.delete(cmr_settings)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cmr_settings changes.

  ## Examples

      iex> change_cmr_settings(cmr_settings)
      %Ecto.Changeset{source: %CMRSetting{}}

  """
  def change_cmr_settings(%CMRSetting{} = cmr_settings) do
    CMRSetting.changeset(cmr_settings, %{})
  end

  @doc """
  Returns the list of bsp_settings.

  ## Examples

      iex> list_bsp_settings()
      [%BSPSetting{}, ...]

  """
  def list_bsp_settings do
    Repo.all(BSPSetting)
  end

  @doc """
  Gets a single bsp_setting.

  Raises `Ecto.NoResultsError` if the Bsp setting does not exist.

  ## Examples

      iex> get_bsp_setting!(123)
      %BSPSetting{}

      iex> get_bsp_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bsp_setting!(id), do: Repo.get!(BSPSetting, id)
  def get_bsp_setting(id), do: Repo.get(BSPSetting, id)

  def get_bsp_settings_by(%{type: type, branch_id: branch_id, slug: slug}) do
    from(s in BSPSetting,
      where: s.type == ^type and s.branch_id == ^branch_id and s.slug in ^slug
    )
    |> Repo.all()
  end

  def get_bsp_settings_by(%{branch_id: branch_id, slug: slug}) do
    from(s in BSPSetting,
      where: s.branch_id == ^branch_id and s.slug == ^slug
    )
    |> Repo.one()
  end

  def get_bsp_settings_by(%{branch_id: branch_id}) do
    from(s in BSPSetting,
      where: s.branch_id == ^branch_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a bsp_setting.

  ## Examples

      iex> create_bsp_setting(%{field: value})
      {:ok, %BSPSetting{}}

      iex> create_bsp_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bsp_setting(attrs \\ %{}) do
    %BSPSetting{}
    |> BSPSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bsp_setting.

  ## Examples

      iex> update_bsp_setting(bsp_setting, %{field: new_value})
      {:ok, %BSPSetting{}}

      iex> update_bsp_setting(bsp_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bsp_setting(%BSPSetting{} = bsp_setting, attrs) do
    bsp_setting
    |> BSPSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bsp_setting.

  ## Examples

      iex> delete_bsp_setting(bsp_setting)
      {:ok, %BSPSetting{}}

      iex> delete_bsp_setting(bsp_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bsp_setting(%BSPSetting{} = bsp_setting) do
    Repo.delete(bsp_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bsp_setting changes.

  ## Examples

      iex> change_bsp_setting(bsp_setting)
      %Ecto.Changeset{source: %BSPSetting{}}

  """
  def change_bsp_setting(%BSPSetting{} = bsp_setting) do
    BSPSetting.changeset(bsp_setting, %{})
  end

  @doc """
  Returns the list of tudo_settings.

  ## Examples

      iex> list_tudo_settings()
      [%TudoSetting{}, ...]

  """
  def list_tudo_settings do
    Repo.all(TudoSetting)
  end

  @doc """
  Gets a single tudo_setting.

  Raises `Ecto.NoResultsError` if the Tudo setting does not exist.

  ## Examples

      iex> get_tudo_setting!(123)
      %TudoSetting{}

      iex> get_tudo_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tudo_setting!(id), do: Repo.get!(TudoSetting, id)
  def get_tudo_setting(id), do: Repo.get(TudoSetting, id)

  @doc """
  Gets a single tudo_setting by slug and country_id.

  Raises `Ecto.NoResultsError` if the Tudo setting does not exist.

  ## Examples

      iex> get_tudo_setting(input)
      %TudoSetting{}

      iex> get_tudo_setting(%{country_id: 1, slug: "mix_file_size"})
      ** (Ecto.NoResultsError)

  """
  def get_tudo_setting_by(%{country_id: country_id, slug: slug}) do
    from(s in TudoSetting,
      where: s.slug == ^slug and (s.country_id == ^country_id or s.country_id == 1)
    )
    |> Repo.one()
  end

  def get_tudo_setting_by(%{slug: slug}) do
    from(s in TudoSetting, where: s.slug == ^slug, order_by: [desc: s.inserted_at], limit: 1)
    |> Repo.one()
  end

  @doc """
  Creates a tudo_setting.

  ## Examples

      iex> create_tudo_setting(%{field: value})
      {:ok, %TudoSetting{}}

      iex> create_tudo_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tudo_setting(attrs \\ %{}) do
    %TudoSetting{}
    |> TudoSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tudo_setting.

  ## Examples

      iex> update_tudo_setting(tudo_setting, %{field: new_value})
      {:ok, %TudoSetting{}}

      iex> update_tudo_setting(tudo_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tudo_setting(%TudoSetting{} = tudo_setting, attrs) do
    tudo_setting
    |> TudoSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tudo_setting.

  ## Examples

      iex> delete_tudo_setting(tudo_setting)
      {:ok, %TudoSetting{}}

      iex> delete_tudo_setting(tudo_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tudo_setting(%TudoSetting{} = tudo_setting) do
    Repo.delete(tudo_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tudo_setting changes.

  ## Examples

      iex> change_tudo_setting(tudo_setting)
      %Ecto.Changeset{source: %TudoSetting{}}

  """
  def change_tudo_setting(%TudoSetting{} = tudo_setting) do
    TudoSetting.changeset(tudo_setting, %{})
  end
end
