defmodule CoreWeb.MetaControllerTest do
  use CoreWeb.ConnCase

  alias Core.MetaData

  @create_attrs %{count: 42, type: "some type"}
  @update_attrs %{count: 43, type: "some updated type"}
  @invalid_attrs %{count: nil, type: nil}

  def fixture(:meta) do
    {:ok, meta} = MetaData.create_meta(@create_attrs)
    meta
  end

  describe "index" do
    test "lists all meta", %{conn: conn} do
      conn = get(conn, Routes.meta_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Meta"
    end
  end

  describe "new meta" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.meta_path(conn, :new))
      assert html_response(conn, 200) =~ "New Meta"
    end
  end

  describe "create meta" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.meta_path(conn, :create), meta: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.meta_path(conn, :show, id)

      conn = get(conn, Routes.meta_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Meta"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.meta_path(conn, :create), meta: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Meta"
    end
  end

  describe "edit meta" do
    setup [:create_meta]

    test "renders form for editing chosen meta", %{conn: conn, meta: meta} do
      conn = get(conn, Routes.meta_path(conn, :edit, meta))
      assert html_response(conn, 200) =~ "Edit Meta"
    end
  end

  describe "update meta" do
    setup [:create_meta]

    test "redirects when data is valid", %{conn: conn, meta: meta} do
      conn = put(conn, Routes.meta_path(conn, :update, meta), meta: @update_attrs)
      assert redirected_to(conn) == Routes.meta_path(conn, :show, meta)

      conn = get(conn, Routes.meta_path(conn, :show, meta))
      assert html_response(conn, 200) =~ "some updated type"
    end

    test "renders errors when data is invalid", %{conn: conn, meta: meta} do
      conn = put(conn, Routes.meta_path(conn, :update, meta), meta: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Meta"
    end
  end

  describe "delete meta" do
    setup [:create_meta]

    test "deletes chosen meta", %{conn: conn, meta: meta} do
      conn = delete(conn, Routes.meta_path(conn, :delete, meta))
      assert redirected_to(conn) == Routes.meta_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.meta_path(conn, :show, meta))
      end
    end
  end

  defp create_meta(_) do
    meta = fixture(:meta)
    {:ok, meta: meta}
  end
end
