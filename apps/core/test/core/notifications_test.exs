defmodule Core.NotificationsTest do
  use Core.DataCase

  alias Core.Notifications

  describe "push_notifications" do
    alias Core.Schemas.PushNotification

    @valid_attrs %{
      acl_role_id: "some acl_role_id",
      description: "some description",
      pushed_at: "2010-04-17T14:00:00Z",
      read: true,
      title: "some title"
    }
    @update_attrs %{
      acl_role_id: "some updated acl_role_id",
      description: "some updated description",
      pushed_at: "2011-05-18T15:01:01Z",
      read: false,
      title: "some updated title"
    }
    @invalid_attrs %{acl_role_id: nil, description: nil, pushed_at: nil, read: nil, title: nil}

    def push_notification_fixture(attrs \\ %{}) do
      {:ok, push_notification} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_push_notification()

      push_notification
    end

    test "list_push_notifications/0 returns all push_notifications" do
      push_notification = push_notification_fixture()
      assert Notifications.list_push_notifications() == [push_notification]
    end

    test "get_push_notification!/1 returns the push_notification with given id" do
      push_notification = push_notification_fixture()
      assert Notifications.get_push_notification!(push_notification.id) == push_notification
    end

    test "create_push_notification/1 with valid data creates a push_notification" do
      assert {:ok, %PushNotification{} = push_notification} =
               Notifications.create_push_notification(@valid_attrs)

      assert push_notification.acl_role_id == "some acl_role_id"
      assert push_notification.description == "some description"

      assert push_notification.pushed_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert push_notification.read == true
      assert push_notification.title == "some title"
    end

    test "create_push_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_push_notification(@invalid_attrs)
    end

    test "update_push_notification/2 with valid data updates the push_notification" do
      push_notification = push_notification_fixture()

      assert {:ok, %PushNotification{} = push_notification} =
               Notifications.update_push_notification(push_notification, @update_attrs)

      assert push_notification.acl_role_id == "some updated acl_role_id"
      assert push_notification.description == "some updated description"

      assert push_notification.pushed_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert push_notification.read == false
      assert push_notification.title == "some updated title"
    end

    test "update_push_notification/2 with invalid data returns error changeset" do
      push_notification = push_notification_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_push_notification(push_notification, @invalid_attrs)

      assert push_notification == Notifications.get_push_notification!(push_notification.id)
    end

    test "delete_push_notification/1 deletes the push_notification" do
      push_notification = push_notification_fixture()

      assert {:ok, %PushNotification{}} =
               Notifications.delete_push_notification(push_notification)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_push_notification!(push_notification.id)
      end
    end

    test "change_push_notification/1 returns a push_notification changeset" do
      push_notification = push_notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_push_notification(push_notification)
    end
  end

  describe "admin_notification_settings" do
    alias Core.Schemas.AdminNotificationSetting

    @valid_attrs %{
      bsp_email: true,
      bsp_notification: true,
      cmr_email: true,
      cmr_notification: true,
      event: "some event",
      slug: "some slug"
    }
    @update_attrs %{
      bsp_email: false,
      bsp_notification: false,
      cmr_email: false,
      cmr_notification: false,
      event: "some updated event",
      slug: "some updated slug"
    }
    @invalid_attrs %{
      bsp_email: nil,
      bsp_notification: nil,
      cmr_email: nil,
      cmr_notification: nil,
      event: nil,
      slug: nil
    }

    def admin_notification_setting_fixture(attrs \\ %{}) do
      {:ok, admin_notification_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Notifications.create_admin_notification_setting()

      admin_notification_setting
    end

    test "list_admin_notification_settings/0 returns all admin_notification_settings" do
      admin_notification_setting = admin_notification_setting_fixture()
      assert Notifications.list_admin_notification_settings() == [admin_notification_setting]
    end

    test "get_admin_notification_setting!/1 returns the admin_notification_setting with given id" do
      admin_notification_setting = admin_notification_setting_fixture()

      assert Notifications.get_admin_notification_setting!(admin_notification_setting.id) ==
               admin_notification_setting
    end

    test "create_admin_notification_setting/1 with valid data creates a admin_notification_setting" do
      assert {:ok, %AdminNotificationSetting{} = admin_notification_setting} =
               Notifications.create_admin_notification_setting(@valid_attrs)

      assert admin_notification_setting.bsp_email == true
      assert admin_notification_setting.bsp_notification == true
      assert admin_notification_setting.cmr_email == true
      assert admin_notification_setting.cmr_notification == true
      assert admin_notification_setting.event == "some event"
      assert admin_notification_setting.slug == "some slug"
    end

    test "create_admin_notification_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_admin_notification_setting(@invalid_attrs)
    end

    test "update_admin_notification_setting/2 with valid data updates the admin_notification_setting" do
      admin_notification_setting = admin_notification_setting_fixture()

      assert {:ok, %AdminNotificationSetting{} = admin_notification_setting} =
               Notifications.update_admin_notification_setting(
                 admin_notification_setting,
                 @update_attrs
               )

      assert admin_notification_setting.bsp_email == false
      assert admin_notification_setting.bsp_notification == false
      assert admin_notification_setting.cmr_email == false
      assert admin_notification_setting.cmr_notification == false
      assert admin_notification_setting.event == "some updated event"
      assert admin_notification_setting.slug == "some updated slug"
    end

    test "update_admin_notification_setting/2 with invalid data returns error changeset" do
      admin_notification_setting = admin_notification_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_admin_notification_setting(
                 admin_notification_setting,
                 @invalid_attrs
               )

      assert admin_notification_setting ==
               Notifications.get_admin_notification_setting!(admin_notification_setting.id)
    end

    test "delete_admin_notification_setting/1 deletes the admin_notification_setting" do
      admin_notification_setting = admin_notification_setting_fixture()

      assert {:ok, %AdminNotificationSetting{}} =
               Notifications.delete_admin_notification_setting(admin_notification_setting)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_admin_notification_setting!(admin_notification_setting.id)
      end
    end

    test "change_admin_notification_setting/1 returns a admin_notification_setting changeset" do
      admin_notification_setting = admin_notification_setting_fixture()

      assert %Ecto.Changeset{} =
               Notifications.change_admin_notification_setting(admin_notification_setting)
    end
  end
end
