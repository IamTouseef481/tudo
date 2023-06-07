defmodule Core.MetaDataTest do
  use Core.DataCase

  alias Core.MetaData

  describe "meta" do
    alias Core.MetaData.Meta

    @valid_attrs %{count: 42, type: "some type"}
    @update_attrs %{count: 43, type: "some updated type"}
    @invalid_attrs %{count: nil, type: nil}

    def meta_fixture(attrs \\ %{}) do
      {:ok, meta} =
        attrs
        |> Enum.into(@valid_attrs)
        |> MetaData.create_meta()

      meta
    end

    test "list_meta/0 returns all meta" do
      meta = meta_fixture()
      assert MetaData.list_meta() == [meta]
    end

    test "get_meta!/1 returns the meta with given id" do
      meta = meta_fixture()
      assert MetaData.get_meta!(meta.id) == meta
    end

    test "create_meta/1 with valid data creates a meta" do
      assert {:ok, %Meta{} = meta} = MetaData.create_meta(@valid_attrs)
      assert meta.count == 42
      assert meta.type == "some type"
    end

    test "create_meta/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MetaData.create_meta(@invalid_attrs)
    end

    test "update_meta/2 with valid data updates the meta" do
      meta = meta_fixture()
      assert {:ok, %Meta{} = meta} = MetaData.update_meta(meta, @update_attrs)
      assert meta.count == 43
      assert meta.type == "some updated type"
    end

    test "update_meta/2 with invalid data returns error changeset" do
      meta = meta_fixture()
      assert {:error, %Ecto.Changeset{}} = MetaData.update_meta(meta, @invalid_attrs)
      assert meta == MetaData.get_meta!(meta.id)
    end

    test "delete_meta/1 deletes the meta" do
      meta = meta_fixture()
      assert {:ok, %Meta{}} = MetaData.delete_meta(meta)
      assert_raise Ecto.NoResultsError, fn -> MetaData.get_meta!(meta.id) end
    end

    test "change_meta/1 returns a meta changeset" do
      meta = meta_fixture()
      assert %Ecto.Changeset{} = MetaData.change_meta(meta)
    end
  end

  describe "meta_cmr" do
    alias Core.Schemas.MetaCMR

    @valid_attrs %{statistics: %{}, type: "some type"}
    @update_attrs %{statistics: %{}, type: "some updated type"}
    @invalid_attrs %{statistics: nil, type: nil}

    def meta_cmr_fixture(attrs \\ %{}) do
      {:ok, meta_cmr} =
        attrs
        |> Enum.into(@valid_attrs)
        |> MetaData.create_meta_cmr()

      meta_cmr
    end

    test "list_meta_cmr/0 returns all meta_cmr" do
      meta_cmr = meta_cmr_fixture()
      assert MetaData.list_meta_cmr() == [meta_cmr]
    end

    test "get_meta_cmr!/1 returns the meta_cmr with given id" do
      meta_cmr = meta_cmr_fixture()
      assert MetaData.get_meta_cmr!(meta_cmr.id) == meta_cmr
    end

    test "create_meta_cmr/1 with valid data creates a meta_cmr" do
      assert {:ok, %MetaCMR{} = meta_cmr} = MetaData.create_meta_cmr(@valid_attrs)
      assert meta_cmr.statistics == %{}
      assert meta_cmr.type == "some type"
    end

    test "create_meta_cmr/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MetaData.create_meta_cmr(@invalid_attrs)
    end

    test "update_meta_cmr/2 with valid data updates the meta_cmr" do
      meta_cmr = meta_cmr_fixture()
      assert {:ok, %MetaCMR{} = meta_cmr} = MetaData.update_meta_cmr(meta_cmr, @update_attrs)
      assert meta_cmr.statistics == %{}
      assert meta_cmr.type == "some updated type"
    end

    test "update_meta_cmr/2 with invalid data returns error changeset" do
      meta_cmr = meta_cmr_fixture()
      assert {:error, %Ecto.Changeset{}} = MetaData.update_meta_cmr(meta_cmr, @invalid_attrs)
      assert meta_cmr == MetaData.get_meta_cmr!(meta_cmr.id)
    end

    test "delete_meta_cmr/1 deletes the meta_cmr" do
      meta_cmr = meta_cmr_fixture()
      assert {:ok, %MetaCMR{}} = MetaData.delete_meta_cmr(meta_cmr)
      assert_raise Ecto.NoResultsError, fn -> MetaData.get_meta_cmr!(meta_cmr.id) end
    end

    test "change_meta_cmr/1 returns a meta_cmr changeset" do
      meta_cmr = meta_cmr_fixture()
      assert %Ecto.Changeset{} = MetaData.change_meta_cmr(meta_cmr)
    end
  end
end
