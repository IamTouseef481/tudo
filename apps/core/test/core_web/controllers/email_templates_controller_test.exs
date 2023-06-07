defmodule CoreWeb.EmailTemplatesControllerTest do
  use CoreWeb.ConnCase

  alias Core.Emails

  @create_attrs %{
    cc: [],
    html_body: "some html_body",
    is_active: true,
    slug: "some slug",
    subject: "some subject",
    text_body: "some text_body"
  }
  @update_attrs %{
    cc: [],
    html_body: "some updated html_body",
    is_active: false,
    slug: "some updated slug",
    subject: "some updated subject",
    text_body: "some updated text_body"
  }
  @invalid_attrs %{
    cc: nil,
    html_body: nil,
    is_active: nil,
    slug: nil,
    subject: nil,
    text_body: nil
  }

  def fixture(:email_templates) do
    {:ok, email_templates} = Emails.create_email_templates(@create_attrs)
    email_templates
  end

  describe "index" do
    test "lists all email_templates", %{conn: conn} do
      conn = get(conn, Routes.email_templates_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Email templates"
    end
  end

  describe "new email_templates" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.email_templates_path(conn, :new))
      assert html_response(conn, 200) =~ "New Email templates"
    end
  end

  describe "create email_templates" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.email_templates_path(conn, :create), email_templates: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.email_templates_path(conn, :show, id)

      conn = get(conn, Routes.email_templates_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Email templates"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.email_templates_path(conn, :create), email_templates: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Email templates"
    end
  end

  describe "edit email_templates" do
    setup [:create_email_templates]

    test "renders form for editing chosen email_templates", %{
      conn: conn,
      email_templates: email_templates
    } do
      conn = get(conn, Routes.email_templates_path(conn, :edit, email_templates))
      assert html_response(conn, 200) =~ "Edit Email templates"
    end
  end

  describe "update email_templates" do
    setup [:create_email_templates]

    test "redirects when data is valid", %{conn: conn, email_templates: email_templates} do
      conn =
        put(conn, Routes.email_templates_path(conn, :update, email_templates),
          email_templates: @update_attrs
        )

      assert redirected_to(conn) == Routes.email_templates_path(conn, :show, email_templates)

      conn = get(conn, Routes.email_templates_path(conn, :show, email_templates))
      assert html_response(conn, 200) =~ ""
    end

    test "renders errors when data is invalid", %{conn: conn, email_templates: email_templates} do
      conn =
        put(conn, Routes.email_templates_path(conn, :update, email_templates),
          email_templates: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Email templates"
    end
  end

  describe "delete email_templates" do
    setup [:create_email_templates]

    test "deletes chosen email_templates", %{conn: conn, email_templates: email_templates} do
      conn = delete(conn, Routes.email_templates_path(conn, :delete, email_templates))
      assert redirected_to(conn) == Routes.email_templates_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.email_templates_path(conn, :show, email_templates))
      end
    end
  end

  defp create_email_templates(_) do
    email_templates = fixture(:email_templates)
    {:ok, email_templates: email_templates}
  end
end
