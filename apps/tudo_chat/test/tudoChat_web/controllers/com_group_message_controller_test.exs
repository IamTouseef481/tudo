defmodule TudoChatWeb.ComGroupMessageControllerTest do
  use TudoChatWeb.ConnCase

  alias TudoChat.Messages

  @create_attrs %{
    content_type: "some content_type",
    is_active: true,
    is_personal: true,
    message: "some message"
  }
  @update_attrs %{
    content_type: "some updated content_type",
    is_active: false,
    is_personal: false,
    message: "some updated message"
  }
  @invalid_attrs %{content_type: nil, is_active: nil, is_personal: nil, message: nil}

  def fixture(:com_group_message) do
    {:ok, com_group_message} = Messages.create_com_group_message(@create_attrs)
    com_group_message
  end

  describe "index" do
    test "lists all com_group_messages", %{conn: conn} do
      conn = get(conn, Routes.com_group_message_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Com group messages"
    end
  end

  describe "new com_group_message" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.com_group_message_path(conn, :new))
      assert html_response(conn, 200) =~ "New Com group message"
    end
  end

  describe "create com_group_message" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.com_group_message_path(conn, :create), com_group_message: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.com_group_message_path(conn, :show, id)

      conn = get(conn, Routes.com_group_message_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Com group message"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.com_group_message_path(conn, :create), com_group_message: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Com group message"
    end
  end

  describe "edit com_group_message" do
    setup [:create_com_group_message]

    test "renders form for editing chosen com_group_message", %{
      conn: conn,
      com_group_message: com_group_message
    } do
      conn = get(conn, Routes.com_group_message_path(conn, :edit, com_group_message))
      assert html_response(conn, 200) =~ "Edit Com group message"
    end
  end

  describe "update com_group_message" do
    setup [:create_com_group_message]

    test "redirects when data is valid", %{conn: conn, com_group_message: com_group_message} do
      conn =
        put(conn, Routes.com_group_message_path(conn, :update, com_group_message),
          com_group_message: @update_attrs
        )

      assert redirected_to(conn) == Routes.com_group_message_path(conn, :show, com_group_message)

      conn = get(conn, Routes.com_group_message_path(conn, :show, com_group_message))
      assert html_response(conn, 200) =~ "some updated content_type"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      com_group_message: com_group_message
    } do
      conn =
        put(conn, Routes.com_group_message_path(conn, :update, com_group_message),
          com_group_message: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Com group message"
    end
  end

  describe "delete com_group_message" do
    setup [:create_com_group_message]

    test "deletes chosen com_group_message", %{conn: conn, com_group_message: com_group_message} do
      conn = delete(conn, Routes.com_group_message_path(conn, :delete, com_group_message))
      assert redirected_to(conn) == Routes.com_group_message_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.com_group_message_path(conn, :show, com_group_message))
      end
    end
  end

  defp create_com_group_message(_) do
    com_group_message = fixture(:com_group_message)
    {:ok, com_group_message: com_group_message}
  end
end
