defmodule CoreWeb.ContinentsControllerTest do
  use CoreWeb.ConnCase

  alias Core.Regions

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}

  def fixture(:continents) do
    {:ok, continents} = Regions.create_continents(@create_attrs)
    continents
  end

  describe "index" do
    test "lists all continents", %{conn: conn} do
      conn = get(conn, Routes.continents_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Continents"
    end
  end

  describe "new continents" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.continents_path(conn, :new))
      assert html_response(conn, 200) =~ "New Continents"
    end
  end

  describe "create continents" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.continents_path(conn, :create), continents: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.continents_path(conn, :show, id)

      conn = get(conn, Routes.continents_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Continents"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.continents_path(conn, :create), continents: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Continents"
    end
  end

  describe "edit continents" do
    setup [:create_continents]

    test "renders form for editing chosen continents", %{conn: conn, continents: continents} do
      conn = get(conn, Routes.continents_path(conn, :edit, continents))
      assert html_response(conn, 200) =~ "Edit Continents"
    end
  end

  describe "update continents" do
    setup [:create_continents]

    test "redirects when data is valid", %{conn: conn, continents: continents} do
      conn =
        put(conn, Routes.continents_path(conn, :update, continents), continents: @update_attrs)

      assert redirected_to(conn) == Routes.continents_path(conn, :show, continents)

      conn = get(conn, Routes.continents_path(conn, :show, continents))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, continents: continents} do
      conn =
        put(conn, Routes.continents_path(conn, :update, continents), continents: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Continents"
    end
  end

  describe "delete continents" do
    setup [:create_continents]

    test "deletes chosen continents", %{conn: conn, continents: continents} do
      conn = delete(conn, Routes.continents_path(conn, :delete, continents))
      assert redirected_to(conn) == Routes.continents_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.continents_path(conn, :show, continents))
      end
    end
  end

  defp create_continents(_) do
    continents = fixture(:continents)
    {:ok, continents: continents}
  end
end
