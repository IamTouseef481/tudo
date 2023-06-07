defmodule Core.Dynamics do
  @moduledoc """
  The Dynamics context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    DynamicBridgeScreensGroup,
    DynamicField,
    DynamicFieldTag,
    DynamicFieldType,
    DynamicFieldValue,
    DynamicGroup,
    DynamicScreen
  }

  def get_dynamic_screens_by(%{country_service_ids: country_service_ids, business_id: business_id}) do
    get_dynamic_screens_by(country_service_ids, business_id)
  end

  def get_dynamic_screens_by(%{country_service_id: country_service_id, business_id: business_id}) do
    get_dynamic_screens_by([country_service_id], business_id)
  end

  def get_dynamic_screens_by(%{country_service_ids: country_service_ids}) do
    business_id = nil
    get_dynamic_screens_by(country_service_ids, business_id)
  end

  def get_dynamic_screens_by(%{country_service_id: country_service_id}) do
    business_id = nil
    get_dynamic_screens_by([country_service_id], business_id)
  end

  def get_dynamic_screens_by(_) do
    {:error, ["Missing country service id"]}
  end

  defp get_dynamic_screens_by(country_service_ids, business_id) do
    screen_groups =
      Repo.all(
        from dsg in DynamicBridgeScreensGroup,
          left_join: dg in DynamicGroup,
          on: dsg.dynamic_group_id == dg.id,
          left_join: ds in DynamicScreen,
          on: dsg.dynamic_screen_id == ds.id,
          left_join: df in assoc(dg, :dynamic_field),
          where: df.is_active and ds.country_service_id in ^country_service_ids,
          order_by: [dsg.dynamic_group_order, df.dynamic_field_order, ds.dynamic_screen_order],
          preload: [dynamic_group: {dg, dynamic_field: df}, dynamic_screen: ds]
      )

    screens =
      Enum.reduce(screen_groups, [], fn screen_group, screens ->
        groups =
          Enum.reduce(screen_groups, [], fn screen_group2, groups ->
            if screen_group.dynamic_screen_id == screen_group2.dynamic_screen_id do
              if screen_group.dynamic_group_id != screen_group2.dynamic_group_id do
                group =
                  Map.merge(screen_group2.dynamic_group, %{
                    dynamic_group_order: screen_group2.dynamic_group_order
                  })

                dynamic_groups = [group | groups]
                Enum.sort(dynamic_groups, &(&1.dynamic_group_order <= &2.dynamic_group_order))
              else
                group =
                  Map.merge(screen_group2.dynamic_group, %{
                    dynamic_group_order: screen_group2.dynamic_group_order
                  })

                dynamic_groups = [group | groups]
                Enum.sort(dynamic_groups, &(&1.dynamic_group_order <= &2.dynamic_group_order))
              end
            else
              Enum.sort(groups, &(&1.dynamic_group_order <= &2.dynamic_group_order))
            end
          end)

        if (screen_group.dynamic_screen.business_id == business_id or
              is_nil(screen_group.dynamic_screen.business_id)) and
             (screen_group.dynamic_group.business_id == business_id or
                is_nil(screen_group.dynamic_group.business_id)) do
          screen = Map.merge(screen_group.dynamic_screen, %{dynamic_group: groups})
          [screen | screens]
        else
          screens
        end
      end)

    screens = Enum.uniq_by(screens, & &1.id)
    Enum.sort(screens, &(&1.dynamic_screen_order <= &2.dynamic_screen_order))

    #    |> Enum.map(fn %{dynamic_group: dynamic_groups}=dynamic_screen ->
    #      if dynamic_screen.business_id == business_id or is_nil(dynamic_screen.business_id) do
    #        dynamic_groups = dynamic_groups |> Enum.filter(& &1.business_id == business_id or is_nil(&1.business_id))
    #        Map.merge(dynamic_screen, %{dynamic_group: dynamic_groups})
    #      end
    #     end)
  end

  @doc """
  Returns the list of dynamic_fields.

  ## Examples

      iex> list_dynamic_fields()
      [%DynamicField{}, ...]

  """
  def list_dynamic_fields do
    Repo.all(DynamicField)
  end

  @doc """
  Gets a single dynamic_field.

  Raises `Ecto.NoResultsError` if the Dynamic field does not exist.

  ## Examples

      iex> get_dynamic_field!(123)
      %DynamicField{}

      iex> get_dynamic_field!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_field(id), do: Repo.get(DynamicField, id)

  def get_dynamic_field_by_id(id) do
    Repo.all(
      from df in DynamicField,
        where: not is_nil(df.business_id) and df.id == ^id
    )
  end

  @doc """
  Creates a dynamic_field.

  ## Examples

      iex> create_dynamic_field(%{field: value})
      {:ok, %DynamicField{}}

      iex> create_dynamic_field(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_field(attrs \\ %{}) do
    %DynamicField{}
    |> DynamicField.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_field.

  ## Examples

      iex> update_dynamic_field(dynamic_field, %{field: new_value})
      {:ok, %DynamicField{}}

      iex> update_dynamic_field(dynamic_field, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_field(%DynamicField{} = dynamic_field, attrs) do
    dynamic_field
    |> DynamicField.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DynamicField.

  ## Examples

      iex> delete_dynamic_field(dynamic_field)
      {:ok, %DynamicField{}}

      iex> delete_dynamic_field(dynamic_screen)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_field(%DynamicField{} = dynamic_field) do
    Repo.delete(dynamic_field)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_screen changes.

  ## Examples

      iex> change_dynamic_screen(dynamic_field)
      %Ecto.Changeset{source: %DynamicField{}}

  """
  def change_dynamic_field(%DynamicField{} = dynamic_field) do
    DynamicField.changeset(dynamic_field, %{})
  end

  @doc """
  Returns the list of dynamic_screens.

  ## Examples

      iex> list_dynamic_screens()
      [%DynamicScreen{}, ...]

  """
  def list_dynamic_screens do
    Repo.all(DynamicScreen)
  end

  @doc """
  Gets a single dynamic_screen.

  Raises `Ecto.NoResultsError` if the Dynamic field does not exist.

  ## Examples

      iex> get_dynamic_screen!(123)
      %DynamicScreen{}

      iex> get_dynamic_screen!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_screen(id), do: Repo.get(DynamicScreen, id)

  def get_dynamic_screen(business_id, country_service_id, name) do
    Repo.all(
      from ds in DynamicScreen,
        where:
          ds.business_id == ^business_id and ds.country_service_id == ^country_service_id and
            ds.name == ^name
    )
  end

  def get_dynamic_screen(country_service_id, name) do
    Repo.all(
      from ds in DynamicScreen,
        where: ds.country_service_id == ^country_service_id and ds.name == ^name
    )
  end

  #
  #  ## check if foreign key exists or not as primary key
  #  def check_foreign_keys(business_id, country_service_id) do
  #    businesses = Repo. from bus in Business, where: bus.business_id == ^business_id
  #    country_services = Repo.all from cs in CountryService, where: cs.country_service_id == ^country_service_id

  #  end
  @doc """
  Creates a dynamic_screen.

  ## Examples

      iex> create_dynamic_screen(%{field: value})
      {:ok, %DynamicScreen{}}

      iex> create_dynamic_screen(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_screen(attrs \\ %{}) do
    %DynamicScreen{}
    |> DynamicScreen.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_screen.

  ## Examples

      iex> update_dynamic_screen(dynamic_screen, %{field: new_value})
      {:ok, %DynamicScreen{}}

      iex> update_dynamic_screen(dynamic_screen, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_screen(%DynamicScreen{} = dynamic_screen, attrs) do
    dynamic_screen
    |> DynamicScreen.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DynamicScreen.

  ## Examples

      iex> delete_dynamic_screen(dynamic_screen)
      {:ok, %DynamicScreen{}}

      iex> delete_dynamic_screen(dynamic_screen)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_screen(%DynamicScreen{} = dynamic_screen) do
    Repo.delete(dynamic_screen)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_screen changes.

  ## Examples

      iex> change_dynamic_screen(dynamic_screen)
      %Ecto.Changeset{source: %DynamicScreen{}}

  """
  def change_dynamic_screen(%DynamicScreen{} = dynamic_screen) do
    DynamicScreen.changeset(dynamic_screen, %{})
  end

  @doc """
  Returns the list of dynamic_groups.

  ## Examples

      iex> list_dynamic_groups()
      [%DynamicGroup{}, ...]

  """
  def list_dynamic_groups do
    Repo.all(DynamicGroup)
  end

  @doc """
  Gets a single dynamic_group.

  Raises `Ecto.NoResultsError` if the Dynamic field does not exist.

  ## Examples

      iex> get_dynamic_group!(123)
      %DynamicGroup{}

      iex> get_dynamic_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_group(id), do: Repo.get(DynamicGroup, id)

  def get_dynamic_group(_business_id, dynamic_screen_id, name) do
    Repo.all(
      from dsg in DynamicBridgeScreensGroup,
        left_join: dg in DynamicGroup,
        on: dsg.dynamic_group_id == dg.id,
        where: dsg.dynamic_screen_id == ^dynamic_screen_id and dg.name == ^name,
        preload: [dynamic_group: dg]
    )
  end

  def get_dynamic_group(dynamic_group_id, dynamic_screen_id) do
    Repo.all(
      from dsg in DynamicBridgeScreensGroup,
        left_join: dg in DynamicGroup,
        on: dsg.dynamic_group_id == dg.id,
        where:
          dsg.dynamic_screen_id == ^dynamic_screen_id and
            dsg.dynamic_group_id == ^dynamic_group_id,
        preload: [dynamic_group: dg]
    )
  end

  def get_dynamic_screen_group(dynamic_group_id, dynamic_screen_id) do
    Repo.all(
      from dsg in DynamicBridgeScreensGroup,
        where:
          dsg.dynamic_screen_id == ^dynamic_screen_id and
            dsg.dynamic_group_id == ^dynamic_group_id
    )
  end

  def get_dynamic_screen_group_by(%{dynamic_screen_id: dynamic_screen_id}) do
    Repo.all(
      from dsg in DynamicBridgeScreensGroup, where: dsg.dynamic_screen_id == ^dynamic_screen_id
    )
  end

  def get_dynamic_screen_group_by(%{dynamic_group_id: dynamic_group_id}) do
    Repo.all(
      from dsg in DynamicBridgeScreensGroup, where: dsg.dynamic_group_id == ^dynamic_group_id
    )
  end

  #
  #  ## check if foreign key exists or not as primary key
  #  def check_foreign_keys(business_id, country_service_id) do
  #    businesses = Repo. from bus in Business, where: bus.business_id == ^business_id
  #    country_services = Repo.all from cs in CountryService, where: cs.country_service_id == ^country_service_id

  #  end
  @doc """
  Creates a dynamic_group.

  ## Examples

      iex> create_dynamic_group(%{field: value})
      {:ok, %DynamicGroup{}}

      iex> create_dynamic_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_group(attrs \\ %{}) do
    %DynamicGroup{}
    |> DynamicGroup.changeset(attrs)
    |> Repo.insert()
  end

  def create_dynamic_screen_group(attrs \\ %{}) do
    %DynamicBridgeScreensGroup{}
    |> DynamicBridgeScreensGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_Group.

  ## Examples

      iex> update_dynamic_group(dynamic_group, %{field: new_value})
      {:ok, %DynamicGroup{}}

      iex> update_dynamic_group(dynamic_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_group(%DynamicGroup{} = dynamic_group, attrs) do
    dynamic_group
    |> DynamicGroup.changeset(attrs)
    |> Repo.update()
  end

  def update_dynamic_screen_group(%DynamicBridgeScreensGroup{} = dynamic_screen_group, attrs) do
    dynamic_screen_group
    |> DynamicBridgeScreensGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DynamicGroup.

  ## Examples

      iex> delete_dynamic_group(dynamic_group)
      {:ok, %DynamicGroup{}}

      iex> delete_dynamic_group(dynamic_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_group(%DynamicGroup{} = dynamic_group) do
    Repo.delete(dynamic_group)
  end

  def delete_dynamic_screen_group(%DynamicBridgeScreensGroup{} = dynamic_screen_group) do
    Repo.delete(dynamic_screen_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_group changes.

  ## Examples

      iex> change_dynamic_group(dynamic_group)
      %Ecto.Changeset{source: %DynamicGroup{}}

  """
  def change_dynamic_group(%DynamicGroup{} = dynamic_group) do
    DynamicGroup.changeset(dynamic_group, %{})
  end

  @doc """
  Returns the list of dynamic_fields_tags.

  ## Examples

      iex> list_dynamic_fields_tags()
      [%DynamicFieldTag{}, ...]

  """
  def list_dynamic_fields_tags do
    Repo.all(DynamicFieldTag)
  end

  @doc """
  Gets a single dynamic_field_tag.

  Raises `Ecto.NoResultsError` if the Dynamic field tag does not exist.

  ## Examples

      iex> get_dynamic_field_tag!(123)
      %DynamicFieldTag{}

      iex> get_dynamic_field_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_field_tag!(id), do: Repo.get!(DynamicFieldTag, id)
  def get_dynamic_field_tag(id), do: Repo.get(DynamicFieldTag, id)

  @doc """
  Creates a dynamic_field_tag.

  ## Examples

      iex> create_dynamic_field_tag(%{field: value})
      {:ok, %DynamicFieldTag{}}

      iex> create_dynamic_field_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_field_tag(attrs \\ %{}) do
    %DynamicFieldTag{}
    |> DynamicFieldTag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_field_tag.

  ## Examples

      iex> update_dynamic_field_tag(dynamic_field_tag, %{field: new_value})
      {:ok, %DynamicFieldTag{}}

      iex> update_dynamic_field_tag(dynamic_field_tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_field_tag(%DynamicFieldTag{} = dynamic_field_tag, attrs) do
    dynamic_field_tag
    |> DynamicFieldTag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dynamic_field_tag.

  ## Examples

      iex> delete_dynamic_field_tag(dynamic_field_tag)
      {:ok, %DynamicFieldTag{}}

      iex> delete_dynamic_field_tag(dynamic_field_tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_field_tag(%DynamicFieldTag{} = dynamic_field_tag) do
    Repo.delete(dynamic_field_tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_field_tag changes.

  ## Examples

      iex> change_dynamic_field_tag(dynamic_field_tag)
      %Ecto.Changeset{source: %DynamicFieldTag{}}

  """
  def change_dynamic_field_tag(%DynamicFieldTag{} = dynamic_field_tag) do
    DynamicFieldTag.changeset(dynamic_field_tag, %{})
  end

  @doc """
  Returns the list of dynamic_field_types.

  ## Examples

      iex> list_dynamic_field_types()
      [%DynamicFieldType{}, ...]

  """
  def list_dynamic_field_types do
    Repo.all(DynamicFieldType)
  end

  @doc """
  Gets a single dynamic_field_type.

  Raises `Ecto.NoResultsError` if the Dynamic field type does not exist.

  ## Examples

      iex> get_dynamic_field_type!(123)
      %DynamicFieldType{}

      iex> get_dynamic_field_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_field_type!(id), do: Repo.get!(DynamicFieldType, id)
  def get_dynamic_field_type(id), do: Repo.get(DynamicFieldType, id)

  @doc """
  Creates a dynamic_field_type.

  ## Examples

      iex> create_dynamic_field_type(%{field: value})
      {:ok, %DynamicFieldType{}}

      iex> create_dynamic_field_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_field_type(attrs \\ %{}) do
    %DynamicFieldType{}
    |> DynamicFieldType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_field_type.

  ## Examples

      iex> update_dynamic_field_type(dynamic_field_type, %{field: new_value})
      {:ok, %DynamicFieldType{}}

      iex> update_dynamic_field_type(dynamic_field_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_field_type(%DynamicFieldType{} = dynamic_field_type, attrs) do
    dynamic_field_type
    |> DynamicFieldType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dynamic_field_type.

  ## Examples

      iex> delete_dynamic_field_type(dynamic_field_type)
      {:ok, %DynamicFieldType{}}

      iex> delete_dynamic_field_type(dynamic_field_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_field_type(%DynamicFieldType{} = dynamic_field_type) do
    Repo.delete(dynamic_field_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_field_type changes.

  ## Examples

      iex> change_dynamic_field_type(dynamic_field_type)
      %Ecto.Changeset{source: %DynamicFieldType{}}

  """
  def change_dynamic_field_type(%DynamicFieldType{} = dynamic_field_type) do
    DynamicFieldType.changeset(dynamic_field_type, %{})
  end

  @doc """
  Returns the list of dynamic_field_value.

  ## Examples

      iex> list_dynamic_field_value()
      [%DynamicFieldValue{}, ...]

  """
  def list_dynamic_field_value do
    Repo.all(DynamicFieldValue)
  end

  @doc """
  Gets a single dynamic_field_value.

  Raises `Ecto.NoResultsError` if the Dynamic field value does not exist.

  ## Examples

      iex> get_dynamic_field_value!(123)
      %DynamicFieldValue{}

      iex> get_dynamic_field_value!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dynamic_field_value!(id), do: Repo.get!(DynamicFieldValue, id)
  def get_dynamic_field_value(id), do: Repo.get(DynamicFieldValue, id)

  @doc """
  Creates a dynamic_field_value.

  ## Examples

      iex> create_dynamic_field_value(%{field: value})
      {:ok, %DynamicFieldValue{}}

      iex> create_dynamic_field_value(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dynamic_field_value(attrs \\ %{}) do
    %DynamicFieldValue{}
    |> DynamicFieldValue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a dynamic_field_value.

  ## Examples

      iex> update_dynamic_field_value(dynamic_field_value, %{field: new_value})
      {:ok, %DynamicFieldValue{}}

      iex> update_dynamic_field_value(dynamic_field_value, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dynamic_field_value(%DynamicFieldValue{} = dynamic_field_value, attrs) do
    dynamic_field_value
    |> DynamicFieldValue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a dynamic_field_value.

  ## Examples

      iex> delete_dynamic_field_value(dynamic_field_value)
      {:ok, %DynamicFieldValue{}}

      iex> delete_dynamic_field_value(dynamic_field_value)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dynamic_field_value(%DynamicFieldValue{} = dynamic_field_value) do
    Repo.delete(dynamic_field_value)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dynamic_field_value changes.

  ## Examples

      iex> change_dynamic_field_value(dynamic_field_value)
      %Ecto.Changeset{source: %DynamicFieldValue{}}

  """
  def change_dynamic_field_value(%DynamicFieldValue{} = dynamic_field_value) do
    DynamicFieldValue.changeset(dynamic_field_value, %{})
  end
end
