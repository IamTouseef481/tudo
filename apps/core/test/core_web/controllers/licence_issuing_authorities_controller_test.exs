defmodule CoreWeb.LicenceIssuingAuthoritiesControllerTest do
  use CoreWeb.ConnCase

  alias Core.Legals

  @create_attrs %{is_active: true, name: "some name"}
  @update_attrs %{is_active: false, name: "some updated name"}
  @invalid_attrs %{is_active: nil, name: nil}

  def fixture(:licence_issuing_authorities) do
    {:ok, licence_issuing_authorities} = Legals.create_licence_issuing_authorities(@create_attrs)
    licence_issuing_authorities
  end

  describe "index" do
    test "lists all licence_issuing_authorities", %{conn: conn} do
      conn = get(conn, Routes.licence_issuing_authorities_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Licence issuing authorities"
    end
  end

  describe "new licence_issuing_authorities" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.licence_issuing_authorities_path(conn, :new))
      assert html_response(conn, 200) =~ "New Licence issuing authorities"
    end
  end

  describe "create licence_issuing_authorities" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.licence_issuing_authorities_path(conn, :create),
          licence_issuing_authorities: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.licence_issuing_authorities_path(conn, :show, id)

      conn = get(conn, Routes.licence_issuing_authorities_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Licence issuing authorities"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.licence_issuing_authorities_path(conn, :create),
          licence_issuing_authorities: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Licence issuing authorities"
    end
  end

  describe "edit licence_issuing_authorities" do
    setup [:create_licence_issuing_authorities]

    test "renders form for editing chosen licence_issuing_authorities", %{
      conn: conn,
      licence_issuing_authorities: licence_issuing_authorities
    } do
      conn =
        get(
          conn,
          Routes.licence_issuing_authorities_path(conn, :edit, licence_issuing_authorities)
        )

      assert html_response(conn, 200) =~ "Edit Licence issuing authorities"
    end
  end

  describe "update licence_issuing_authorities" do
    setup [:create_licence_issuing_authorities]

    test "redirects when data is valid", %{
      conn: conn,
      licence_issuing_authorities: licence_issuing_authorities
    } do
      conn =
        put(
          conn,
          Routes.licence_issuing_authorities_path(conn, :update, licence_issuing_authorities),
          licence_issuing_authorities: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.licence_issuing_authorities_path(conn, :show, licence_issuing_authorities)

      conn =
        get(
          conn,
          Routes.licence_issuing_authorities_path(conn, :show, licence_issuing_authorities)
        )

      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      licence_issuing_authorities: licence_issuing_authorities
    } do
      conn =
        put(
          conn,
          Routes.licence_issuing_authorities_path(conn, :update, licence_issuing_authorities),
          licence_issuing_authorities: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Licence issuing authorities"
    end
  end

  describe "delete licence_issuing_authorities" do
    setup [:create_licence_issuing_authorities]

    test "deletes chosen licence_issuing_authorities", %{
      conn: conn,
      licence_issuing_authorities: licence_issuing_authorities
    } do
      conn =
        delete(
          conn,
          Routes.licence_issuing_authorities_path(conn, :delete, licence_issuing_authorities)
        )

      assert redirected_to(conn) == Routes.licence_issuing_authorities_path(conn, :index)

      assert_error_sent 404, fn ->
        get(
          conn,
          Routes.licence_issuing_authorities_path(conn, :show, licence_issuing_authorities)
        )
      end
    end
  end

  defp create_licence_issuing_authorities(_) do
    licence_issuing_authorities = fixture(:licence_issuing_authorities)
    {:ok, licence_issuing_authorities: licence_issuing_authorities}
  end
end
