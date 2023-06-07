defmodule TudoChatWeb.UserControllerTest do
  use TudoChatWeb.ConnCase

  alias TudoChat.Accounts

  @create_attrs %{
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

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated confirmation_token"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
