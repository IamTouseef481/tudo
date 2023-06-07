defmodule Core.SettingsTest do
  use Core.DataCase

  alias Core.Settings

  describe "settings" do
    alias Core.Schemas.Setting

    @valid_attrs %{fields: %{}, slug: "some slug", title: "some title", "type,": "some type,"}
    @update_attrs %{
      fields: %{},
      slug: "some updated slug",
      title: "some updated title",
      "type,": "some updated type,"
    }
    @invalid_attrs %{fields: nil, slug: nil, title: nil, "type,": nil}

    def setting_fixture(attrs \\ %{}) do
      {:ok, setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_setting()

      setting
    end

    test "list_settings/0 returns all settings" do
      setting = setting_fixture()
      assert Settings.list_settings() == [setting]
    end

    test "get_setting!/1 returns the setting with given id" do
      setting = setting_fixture()
      assert Settings.get_setting!(setting.id) == setting
    end

    test "create_setting/1 with valid data creates a setting" do
      assert {:ok, %Setting{} = setting} = Settings.create_setting(@valid_attrs)
      assert setting.fields == %{}
      assert setting.slug == "some slug"
      assert setting.title == "some title"
      assert setting.type == "some type,"
    end

    test "create_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_setting(@invalid_attrs)
    end

    test "update_setting/2 with valid data updates the setting" do
      setting = setting_fixture()
      assert {:ok, %Setting{} = setting} = Settings.update_setting(setting, @update_attrs)
      assert setting.fields == %{}
      assert setting.slug == "some updated slug"
      assert setting.title == "some updated title"
      assert setting.type == "some updated type,"
    end

    test "update_setting/2 with invalid data returns error changeset" do
      setting = setting_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_setting(setting, @invalid_attrs)
      assert setting == Settings.get_setting!(setting.id)
    end

    test "delete_setting/1 deletes the setting" do
      setting = setting_fixture()
      assert {:ok, %Setting{}} = Settings.delete_setting(setting)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_setting!(setting.id) end
    end

    test "change_setting/1 returns a setting changeset" do
      setting = setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_setting(setting)
    end
  end

  describe "additional_details" do
    alias Core.Settings.AdditionalDetails

    @valid_attrs %{insurance: [], qualification: [], vehicles: [], work_experience: []}
    @update_attrs %{insurance: [], qualification: [], vehicles: [], work_experience: []}
    @invalid_attrs %{insurance: nil, qualification: nil, vehicles: nil, work_experience: nil}

    def additional_details_fixture(attrs \\ %{}) do
      {:ok, additional_details} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_additional_details()

      additional_details
    end

    test "list_additional_details/0 returns all additional_details" do
      additional_details = additional_details_fixture()
      assert Settings.list_additional_details() == [additional_details]
    end

    test "get_additional_details!/1 returns the additional_details with given id" do
      additional_details = additional_details_fixture()
      assert Settings.get_additional_details!(additional_details.id) == additional_details
    end

    test "create_additional_details/1 with valid data creates a additional_details" do
      assert {:ok, %AdditionalDetails{} = additional_details} =
               Settings.create_additional_details(@valid_attrs)

      assert additional_details.insurance == []
      assert additional_details.qualification == []
      assert additional_details.vehicles == []
      assert additional_details.work_experience == []
    end

    test "create_additional_details/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_additional_details(@invalid_attrs)
    end

    test "update_additional_details/2 with valid data updates the additional_details" do
      additional_details = additional_details_fixture()

      assert {:ok, %AdditionalDetails{} = additional_details} =
               Settings.update_additional_details(additional_details, @update_attrs)

      assert additional_details.insurance == []
      assert additional_details.qualification == []
      assert additional_details.vehicles == []
      assert additional_details.work_experience == []
    end

    test "update_additional_details/2 with invalid data returns error changeset" do
      additional_details = additional_details_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_additional_details(additional_details, @invalid_attrs)

      assert additional_details == Settings.get_additional_details!(additional_details.id)
    end

    test "delete_additional_details/1 deletes the additional_details" do
      additional_details = additional_details_fixture()
      assert {:ok, %AdditionalDetails{}} = Settings.delete_additional_details(additional_details)

      assert_raise Ecto.NoResultsError, fn ->
        Settings.get_additional_details!(additional_details.id)
      end
    end

    test "change_additional_details/1 returns a additional_details changeset" do
      additional_details = additional_details_fixture()
      assert %Ecto.Changeset{} = Settings.change_additional_details(additional_details)
    end
  end

  describe "bsp_settings" do
    alias Core.Schemas.BSPSetting

    @valid_attrs %{fields: [], slug: "some slug", title: "some title", type: "some type"}
    @update_attrs %{
      fields: [],
      slug: "some updated slug",
      title: "some updated title",
      type: "some updated type"
    }
    @invalid_attrs %{fields: nil, slug: nil, title: nil, type: nil}

    def bsp_setting_fixture(attrs \\ %{}) do
      {:ok, bsp_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_bsp_setting()

      bsp_setting
    end

    test "list_bsp_settings/0 returns all bsp_settings" do
      bsp_setting = bsp_setting_fixture()
      assert Settings.list_bsp_settings() == [bsp_setting]
    end

    test "get_bsp_setting!/1 returns the bsp_setting with given id" do
      bsp_setting = bsp_setting_fixture()
      assert Settings.get_bsp_setting!(bsp_setting.id) == bsp_setting
    end

    test "create_bsp_setting/1 with valid data creates a bsp_setting" do
      assert {:ok, %BSPSetting{} = bsp_setting} = Settings.create_bsp_setting(@valid_attrs)
      assert bsp_setting.fields == []
      assert bsp_setting.slug == "some slug"
      assert bsp_setting.title == "some title"
      assert bsp_setting.type == "some type"
    end

    test "create_bsp_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_bsp_setting(@invalid_attrs)
    end

    test "update_bsp_setting/2 with valid data updates the bsp_setting" do
      bsp_setting = bsp_setting_fixture()

      assert {:ok, %BSPSetting{} = bsp_setting} =
               Settings.update_bsp_setting(bsp_setting, @update_attrs)

      assert bsp_setting.fields == []
      assert bsp_setting.slug == "some updated slug"
      assert bsp_setting.title == "some updated title"
      assert bsp_setting.type == "some updated type"
    end

    test "update_bsp_setting/2 with invalid data returns error changeset" do
      bsp_setting = bsp_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_bsp_setting(bsp_setting, @invalid_attrs)

      assert bsp_setting == Settings.get_bsp_setting!(bsp_setting.id)
    end

    test "delete_bsp_setting/1 deletes the bsp_setting" do
      bsp_setting = bsp_setting_fixture()
      assert {:ok, %BSPSetting{}} = Settings.delete_bsp_setting(bsp_setting)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_bsp_setting!(bsp_setting.id) end
    end

    test "change_bsp_setting/1 returns a bsp_setting changeset" do
      bsp_setting = bsp_setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_bsp_setting(bsp_setting)
    end
  end

  describe "tudo_settings" do
    alias Core.Schemas.TudoSetting

    @valid_attrs %{
      is_active: true,
      slug: "some slug",
      title: "some title",
      unit: "some unit",
      value: 120.5
    }
    @update_attrs %{
      is_active: false,
      slug: "some updated slug",
      title: "some updated title",
      unit: "some updated unit",
      value: 456.7
    }
    @invalid_attrs %{is_active: nil, slug: nil, title: nil, unit: nil, value: nil}

    def tudo_setting_fixture(attrs \\ %{}) do
      {:ok, tudo_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_tudo_setting()

      tudo_setting
    end

    test "list_tudo_settings/0 returns all tudo_settings" do
      tudo_setting = tudo_setting_fixture()
      assert Settings.list_tudo_settings() == [tudo_setting]
    end

    test "get_tudo_setting!/1 returns the tudo_setting with given id" do
      tudo_setting = tudo_setting_fixture()
      assert Settings.get_tudo_setting!(tudo_setting.id) == tudo_setting
    end

    test "create_tudo_setting/1 with valid data creates a tudo_setting" do
      assert {:ok, %TudoSetting{} = tudo_setting} = Settings.create_tudo_setting(@valid_attrs)
      assert tudo_setting.is_active == true
      assert tudo_setting.slug == "some slug"
      assert tudo_setting.title == "some title"
      assert tudo_setting.unit == "some unit"
      assert tudo_setting.value == 120.5
    end

    test "create_tudo_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_tudo_setting(@invalid_attrs)
    end

    test "update_tudo_setting/2 with valid data updates the tudo_setting" do
      tudo_setting = tudo_setting_fixture()

      assert {:ok, %TudoSetting{} = tudo_setting} =
               Settings.update_tudo_setting(tudo_setting, @update_attrs)

      assert tudo_setting.is_active == false
      assert tudo_setting.slug == "some updated slug"
      assert tudo_setting.title == "some updated title"
      assert tudo_setting.unit == "some updated unit"
      assert tudo_setting.value == 456.7
    end

    test "update_tudo_setting/2 with invalid data returns error changeset" do
      tudo_setting = tudo_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_tudo_setting(tudo_setting, @invalid_attrs)

      assert tudo_setting == Settings.get_tudo_setting!(tudo_setting.id)
    end

    test "delete_tudo_setting/1 deletes the tudo_setting" do
      tudo_setting = tudo_setting_fixture()
      assert {:ok, %TudoSetting{}} = Settings.delete_tudo_setting(tudo_setting)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_tudo_setting!(tudo_setting.id) end
    end

    test "change_tudo_setting/1 returns a tudo_setting changeset" do
      tudo_setting = tudo_setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_tudo_setting(tudo_setting)
    end
  end
end
