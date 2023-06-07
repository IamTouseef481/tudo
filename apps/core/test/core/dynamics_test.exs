defmodule Core.DynamicsTest do
  use Core.DataCase

  alias Core.Dynamics

  describe "dynamic_fields" do
    alias Core.Schemas.DynamicField

    @valid_attrs %{fields: %{}, is_active: true}
    @update_attrs %{fields: %{}, is_active: false}
    @invalid_attrs %{fields: nil, is_active: nil}

    def dynamic_field_fixture(attrs \\ %{}) do
      {:ok, dynamic_field} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dynamics.create_dynamic_field()

      dynamic_field
    end

    test "list_dynamic_fields/0 returns all dynamic_fields" do
      dynamic_field = dynamic_field_fixture()
      assert Dynamics.list_dynamic_fields() == [dynamic_field]
    end

    test "get_dynamic_field!/1 returns the dynamic_field with given id" do
      dynamic_field = dynamic_field_fixture()
      assert Dynamics.get_dynamic_field!(dynamic_field.id) == dynamic_field
    end

    test "create_dynamic_field/1 with valid data creates a dynamic_field" do
      assert {:ok, %DynamicField{} = dynamic_field} = Dynamics.create_dynamic_field(@valid_attrs)
      assert dynamic_field.fields == %{}
      assert dynamic_field.is_active == true
    end

    test "create_dynamic_field/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dynamics.create_dynamic_field(@invalid_attrs)
    end

    test "update_dynamic_field/2 with valid data updates the dynamic_field" do
      dynamic_field = dynamic_field_fixture()

      assert {:ok, %DynamicField{} = dynamic_field} =
               Dynamics.update_dynamic_field(dynamic_field, @update_attrs)

      assert dynamic_field.fields == %{}
      assert dynamic_field.is_active == false
    end

    test "update_dynamic_field/2 with invalid data returns error changeset" do
      dynamic_field = dynamic_field_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Dynamics.update_dynamic_field(dynamic_field, @invalid_attrs)

      assert dynamic_field == Dynamics.get_dynamic_field!(dynamic_field.id)
    end

    test "delete_dynamic_field/1 deletes the dynamic_field" do
      dynamic_field = dynamic_field_fixture()
      assert {:ok, %DynamicField{}} = Dynamics.delete_dynamic_field(dynamic_field)
      assert_raise Ecto.NoResultsError, fn -> Dynamics.get_dynamic_field!(dynamic_field.id) end
    end

    test "change_dynamic_field/1 returns a dynamic_field changeset" do
      dynamic_field = dynamic_field_fixture()
      assert %Ecto.Changeset{} = Dynamics.change_dynamic_field(dynamic_field)
    end
  end

  describe "dynamic_fields_tags" do
    alias Core.Schemas.DynamicFieldTag

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def dynamic_field_tag_fixture(attrs \\ %{}) do
      {:ok, dynamic_field_tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dynamics.create_dynamic_field_tag()

      dynamic_field_tag
    end

    test "list_dynamic_fields_tags/0 returns all dynamic_fields_tags" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert Dynamics.list_dynamic_fields_tags() == [dynamic_field_tag]
    end

    test "get_dynamic_field_tag!/1 returns the dynamic_field_tag with given id" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id) == dynamic_field_tag
    end

    test "create_dynamic_field_tag/1 with valid data creates a dynamic_field_tag" do
      assert {:ok, %DynamicFieldTag{} = dynamic_field_tag} =
               Dynamics.create_dynamic_field_tag(@valid_attrs)

      assert dynamic_field_tag.description == "some description"
      assert dynamic_field_tag.id == "some id"
    end

    test "create_dynamic_field_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dynamics.create_dynamic_field_tag(@invalid_attrs)
    end

    test "update_dynamic_field_tag/2 with valid data updates the dynamic_field_tag" do
      dynamic_field_tag = dynamic_field_tag_fixture()

      assert {:ok, %DynamicFieldTag{} = dynamic_field_tag} =
               Dynamics.update_dynamic_field_tag(dynamic_field_tag, @update_attrs)

      assert dynamic_field_tag.description == "some updated description"
      assert dynamic_field_tag.id == "some updated id"
    end

    test "update_dynamic_field_tag/2 with invalid data returns error changeset" do
      dynamic_field_tag = dynamic_field_tag_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Dynamics.update_dynamic_field_tag(dynamic_field_tag, @invalid_attrs)

      assert dynamic_field_tag == Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id)
    end

    test "delete_dynamic_field_tag/1 deletes the dynamic_field_tag" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert {:ok, %DynamicFieldTag{}} = Dynamics.delete_dynamic_field_tag(dynamic_field_tag)

      assert_raise Ecto.NoResultsError, fn ->
        Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id)
      end
    end

    test "change_dynamic_field_tag/1 returns a dynamic_field_tag changeset" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert %Ecto.Changeset{} = Dynamics.change_dynamic_field_tag(dynamic_field_tag)
    end
  end

  describe "dynamic_field_types" do
    alias Core.Schemas.DynamicFieldType

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def dynamic_field_type_fixture(attrs \\ %{}) do
      {:ok, dynamic_field_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dynamics.create_dynamic_field_type()

      dynamic_field_type
    end

    test "list_dynamic_field_types/0 returns all dynamic_field_types" do
      dynamic_field_type = dynamic_field_type_fixture()
      assert Dynamics.list_dynamic_field_types() == [dynamic_field_type]
    end

    test "get_dynamic_field_type!/1 returns the dynamic_field_type with given id" do
      dynamic_field_type = dynamic_field_type_fixture()
      assert Dynamics.get_dynamic_field_type!(dynamic_field_type.id) == dynamic_field_type
    end

    test "create_dynamic_field_type/1 with valid data creates a dynamic_field_type" do
      assert {:ok, %DynamicFieldType{} = dynamic_field_type} =
               Dynamics.create_dynamic_field_type(@valid_attrs)

      assert dynamic_field_type.description == "some description"
      assert dynamic_field_type.id == "some id"
    end

    test "create_dynamic_field_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dynamics.create_dynamic_field_type(@invalid_attrs)
    end

    test "update_dynamic_field_type/2 with valid data updates the dynamic_field_type" do
      dynamic_field_type = dynamic_field_type_fixture()

      assert {:ok, %DynamicFieldType{} = dynamic_field_type} =
               Dynamics.update_dynamic_field_type(dynamic_field_type, @update_attrs)

      assert dynamic_field_type.description == "some updated description"
      assert dynamic_field_type.id == "some updated id"
    end

    test "update_dynamic_field_type/2 with invalid data returns error changeset" do
      dynamic_field_type = dynamic_field_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Dynamics.update_dynamic_field_type(dynamic_field_type, @invalid_attrs)

      assert dynamic_field_type == Dynamics.get_dynamic_field_type!(dynamic_field_type.id)
    end

    test "delete_dynamic_field_type/1 deletes the dynamic_field_type" do
      dynamic_field_type = dynamic_field_type_fixture()
      assert {:ok, %DynamicFieldType{}} = Dynamics.delete_dynamic_field_type(dynamic_field_type)

      assert_raise Ecto.NoResultsError, fn ->
        Dynamics.get_dynamic_field_type!(dynamic_field_type.id)
      end
    end

    test "change_dynamic_field_type/1 returns a dynamic_field_type changeset" do
      dynamic_field_type = dynamic_field_type_fixture()
      assert %Ecto.Changeset{} = Dynamics.change_dynamic_field_type(dynamic_field_type)
    end
  end

  describe "dynamic_field_values" do
    alias Core.Schemas.DynamicFieldValues

    @valid_attrs %{end_point: %{}, fixed: %{}, id: "some id", query: %{}}
    @update_attrs %{end_point: %{}, fixed: %{}, id: "some updated id", query: %{}}
    @invalid_attrs %{end_point: nil, fixed: nil, id: nil, query: nil}

    def dynamic_field_values_fixture(attrs \\ %{}) do
      {:ok, dynamic_field_values} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dynamics.create_dynamic_field_values()

      dynamic_field_values
    end

    test "list_dynamic_field_values/0 returns all dynamic_field_values" do
      dynamic_field_values = dynamic_field_values_fixture()
      assert Dynamics.list_dynamic_field_values() == [dynamic_field_values]
    end

    test "get_dynamic_field_values!/1 returns the dynamic_field_values with given id" do
      dynamic_field_values = dynamic_field_values_fixture()
      assert Dynamics.get_dynamic_field_values!(dynamic_field_values.id) == dynamic_field_values
    end

    test "create_dynamic_field_values/1 with valid data creates a dynamic_field_values" do
      assert {:ok, %DynamicFieldValues{} = dynamic_field_values} =
               Dynamics.create_dynamic_field_values(@valid_attrs)

      assert dynamic_field_values.end_point == %{}
      assert dynamic_field_values.fixed == %{}
      assert dynamic_field_values.id == "some id"
      assert dynamic_field_values.query == %{}
    end

    test "create_dynamic_field_values/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dynamics.create_dynamic_field_values(@invalid_attrs)
    end

    test "update_dynamic_field_values/2 with valid data updates the dynamic_field_values" do
      dynamic_field_values = dynamic_field_values_fixture()

      assert {:ok, %DynamicFieldValues{} = dynamic_field_values} =
               Dynamics.update_dynamic_field_values(dynamic_field_values, @update_attrs)

      assert dynamic_field_values.end_point == %{}
      assert dynamic_field_values.fixed == %{}
      assert dynamic_field_values.id == "some updated id"
      assert dynamic_field_values.query == %{}
    end

    test "update_dynamic_field_values/2 with invalid data returns error changeset" do
      dynamic_field_values = dynamic_field_values_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Dynamics.update_dynamic_field_values(dynamic_field_values, @invalid_attrs)

      assert dynamic_field_values == Dynamics.get_dynamic_field_values!(dynamic_field_values.id)
    end

    test "delete_dynamic_field_values/1 deletes the dynamic_field_values" do
      dynamic_field_values = dynamic_field_values_fixture()

      assert {:ok, %DynamicFieldValues{}} =
               Dynamics.delete_dynamic_field_values(dynamic_field_values)

      assert_raise Ecto.NoResultsError, fn ->
        Dynamics.get_dynamic_field_values!(dynamic_field_values.id)
      end
    end

    test "change_dynamic_field_values/1 returns a dynamic_field_values changeset" do
      dynamic_field_values = dynamic_field_values_fixture()
      assert %Ecto.Changeset{} = Dynamics.change_dynamic_field_values(dynamic_field_values)
    end
  end

  describe "dynamic_field_tags" do
    alias Core.Schemas.DynamicFieldTag

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def dynamic_field_tag_fixture(attrs \\ %{}) do
      {:ok, dynamic_field_tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Dynamics.create_dynamic_field_tag()

      dynamic_field_tag
    end

    test "list_dynamic_field_tags/0 returns all dynamic_field_tags" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert Dynamics.list_dynamic_field_tags() == [dynamic_field_tag]
    end

    test "get_dynamic_field_tag!/1 returns the dynamic_field_tag with given id" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id) == dynamic_field_tag
    end

    test "create_dynamic_field_tag/1 with valid data creates a dynamic_field_tag" do
      assert {:ok, %DynamicFieldTag{} = dynamic_field_tag} =
               Dynamics.create_dynamic_field_tag(@valid_attrs)

      assert dynamic_field_tag.description == "some description"
      assert dynamic_field_tag.id == "some id"
    end

    test "create_dynamic_field_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dynamics.create_dynamic_field_tag(@invalid_attrs)
    end

    test "update_dynamic_field_tag/2 with valid data updates the dynamic_field_tag" do
      dynamic_field_tag = dynamic_field_tag_fixture()

      assert {:ok, %DynamicFieldTag{} = dynamic_field_tag} =
               Dynamics.update_dynamic_field_tag(dynamic_field_tag, @update_attrs)

      assert dynamic_field_tag.description == "some updated description"
      assert dynamic_field_tag.id == "some updated id"
    end

    test "update_dynamic_field_tag/2 with invalid data returns error changeset" do
      dynamic_field_tag = dynamic_field_tag_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Dynamics.update_dynamic_field_tag(dynamic_field_tag, @invalid_attrs)

      assert dynamic_field_tag == Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id)
    end

    test "delete_dynamic_field_tag/1 deletes the dynamic_field_tag" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert {:ok, %DynamicFieldTag{}} = Dynamics.delete_dynamic_field_tag(dynamic_field_tag)

      assert_raise Ecto.NoResultsError, fn ->
        Dynamics.get_dynamic_field_tag!(dynamic_field_tag.id)
      end
    end

    test "change_dynamic_field_tag/1 returns a dynamic_field_tag changeset" do
      dynamic_field_tag = dynamic_field_tag_fixture()
      assert %Ecto.Changeset{} = Dynamics.change_dynamic_field_tag(dynamic_field_tag)
    end
  end
end
