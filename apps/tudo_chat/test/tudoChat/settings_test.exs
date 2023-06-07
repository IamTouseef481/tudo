defmodule TudoChat.SettingsTest do
  use TudoChat.DataCase

  alias TudoChat.Settings

  describe "settings" do
    alias TudoChat.Settings.Setting

    @valid_attrs %{
      fields: %{},
      slug: "some slug",
      title: "some title",
      type: "some type",
      user_id: 42
    }
    @update_attrs %{
      fields: %{},
      slug: "some updated slug",
      title: "some updated title",
      type: "some updated type",
      user_id: 43
    }
    @invalid_attrs %{fields: nil, slug: nil, title: nil, type: nil, user_id: nil}

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
      assert setting.type == "some type"
      assert setting.user_id == 42
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
      assert setting.type == "some updated type"
      assert setting.user_id == 43
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

  describe "group_settings" do
    alias TudoChat.Settings.GroupSetting

    @valid_attrs %{
      fields: %{},
      slug: "some slug",
      title: "some title",
      type: "some type",
      user_id: 42
    }
    @update_attrs %{
      fields: %{},
      slug: "some updated slug",
      title: "some updated title",
      type: "some updated type",
      user_id: 43
    }
    @invalid_attrs %{fields: nil, slug: nil, title: nil, type: nil, user_id: nil}

    def group_setting_fixture(attrs \\ %{}) do
      {:ok, group_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_group_setting()

      group_setting
    end

    test "list_group_settings/0 returns all group_settings" do
      group_setting = group_setting_fixture()
      assert Settings.list_group_settings() == [group_setting]
    end

    test "get_group_setting!/1 returns the group_setting with given id" do
      group_setting = group_setting_fixture()
      assert Settings.get_group_setting!(group_setting.id) == group_setting
    end

    test "create_group_setting/1 with valid data creates a group_setting" do
      assert {:ok, %GroupSetting{} = group_setting} = Settings.create_group_setting(@valid_attrs)
      assert group_setting.fields == %{}
      assert group_setting.slug == "some slug"
      assert group_setting.title == "some title"
      assert group_setting.type == "some type"
      assert group_setting.user_id == 42
    end

    test "create_group_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_group_setting(@invalid_attrs)
    end

    test "update_group_setting/2 with valid data updates the group_setting" do
      group_setting = group_setting_fixture()

      assert {:ok, %GroupSetting{} = group_setting} =
               Settings.update_group_setting(group_setting, @update_attrs)

      assert group_setting.fields == %{}
      assert group_setting.slug == "some updated slug"
      assert group_setting.title == "some updated title"
      assert group_setting.type == "some updated type"
      assert group_setting.user_id == 43
    end

    test "update_group_setting/2 with invalid data returns error changeset" do
      group_setting = group_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Settings.update_group_setting(group_setting, @invalid_attrs)

      assert group_setting == Settings.get_group_setting!(group_setting.id)
    end

    test "delete_group_setting/1 deletes the group_setting" do
      group_setting = group_setting_fixture()
      assert {:ok, %GroupSetting{}} = Settings.delete_group_setting(group_setting)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_group_setting!(group_setting.id) end
    end

    test "change_group_setting/1 returns a group_setting changeset" do
      group_setting = group_setting_fixture()
      assert %Ecto.Changeset{} = Settings.change_group_setting(group_setting)
    end
  end
end
