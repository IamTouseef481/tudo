defmodule TudoChat.AccountsTest do
  use TudoChat.DataCase

  alias TudoChat.Accounts

  describe "users" do
    alias TudoChat.Accounts.User

    @valid_attrs %{
      business_id: 42,
      confirmation_sent_at: "2010-04-17T14:00:00Z",
      confirmation_token: "some confirmation_token",
      confirmed_at: "2010-04-17T14:00:00Z",
      current_sign_in_at: "2010-04-17T14:00:00Z",
      email: "some email",
      failed_attempts: 42,
      is_verified: true,
      locked_at: "2010-04-17T14:00:00Z",
      mobile: "some mobile",
      password_hash: "some password_hash",
      platform_terms_and_condition_id: 42,
      profile: %{},
      reset_password_sent_at: "2010-04-17T14:00:00Z",
      reset_password_token: "some reset_password_token",
      scopes: "some scopes",
      sign_in_count: 42,
      unlock_token: "some unlock_token"
    }
    @update_attrs %{
      business_id: 43,
      confirmation_sent_at: "2011-05-18T15:01:01Z",
      confirmation_token: "some updated confirmation_token",
      confirmed_at: "2011-05-18T15:01:01Z",
      current_sign_in_at: "2011-05-18T15:01:01Z",
      email: "some updated email",
      failed_attempts: 43,
      is_verified: false,
      locked_at: "2011-05-18T15:01:01Z",
      mobile: "some updated mobile",
      password_hash: "some updated password_hash",
      platform_terms_and_condition_id: 43,
      profile: %{},
      reset_password_sent_at: "2011-05-18T15:01:01Z",
      reset_password_token: "some updated reset_password_token",
      scopes: "some updated scopes",
      sign_in_count: 43,
      unlock_token: "some updated unlock_token"
    }
    @invalid_attrs %{
      business_id: nil,
      confirmation_sent_at: nil,
      confirmation_token: nil,
      confirmed_at: nil,
      current_sign_in_at: nil,
      email: nil,
      failed_attempts: nil,
      is_verified: nil,
      locked_at: nil,
      mobile: nil,
      password_hash: nil,
      platform_terms_and_condition_id: nil,
      profile: nil,
      reset_password_sent_at: nil,
      reset_password_token: nil,
      scopes: nil,
      sign_in_count: nil,
      unlock_token: nil
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.business_id == 42

      assert user.confirmation_sent_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert user.confirmation_token == "some confirmation_token"
      assert user.confirmed_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.current_sign_in_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.email == "some email"
      assert user.failed_attempts == 42
      assert user.is_verified == true
      assert user.locked_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user.mobile == "some mobile"
      assert user.password_hash == "some password_hash"
      assert user.platform_terms_and_condition_id == 42
      assert user.profile == %{}

      assert user.reset_password_sent_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert user.reset_password_token == "some reset_password_token"
      assert user.scopes == "some scopes"
      assert user.sign_in_count == 42
      assert user.unlock_token == "some unlock_token"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.business_id == 43

      assert user.confirmation_sent_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert user.confirmation_token == "some updated confirmation_token"
      assert user.confirmed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.current_sign_in_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.email == "some updated email"
      assert user.failed_attempts == 43
      assert user.is_verified == false
      assert user.locked_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user.mobile == "some updated mobile"
      assert user.password_hash == "some updated password_hash"
      assert user.platform_terms_and_condition_id == 43
      assert user.profile == %{}

      assert user.reset_password_sent_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")

      assert user.reset_password_token == "some updated reset_password_token"
      assert user.scopes == "some updated scopes"
      assert user.sign_in_count == 43
      assert user.unlock_token == "some updated unlock_token"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "sessions" do
    alias TudoChat.Accounts.Session

    @valid_attrs %{tenant: "some tenant", token: "some token"}
    @update_attrs %{tenant: "some updated tenant", token: "some updated token"}
    @invalid_attrs %{tenant: nil, token: nil}

    def session_fixture(attrs \\ %{}) do
      {:ok, session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_session()

      session
    end

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Accounts.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Accounts.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      assert {:ok, %Session{} = session} = Accounts.create_session(@valid_attrs)
      assert session.tenant == "some tenant"
      assert session.token == "some token"
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      assert {:ok, %Session{} = session} = Accounts.update_session(session, @update_attrs)
      assert session.tenant == "some updated tenant"
      assert session.token == "some updated token"
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_session(session, @invalid_attrs)
      assert session == Accounts.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Accounts.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Accounts.change_session(session)
    end
  end
end
