defmodule CoreWeb.PlatformTermsAndConditionsControllerTest do
  use CoreWeb.ConnCase

  alias Core.Policy

  @create_attrs %{
    country_id: 42,
    end_date: "2010-04-17T14:00:00Z",
    start_date: "2010-04-17T14:00:00Z",
    type: "some type",
    url: "some url"
  }
  @update_attrs %{
    country_id: 43,
    end_date: "2011-05-18T15:01:01Z",
    start_date: "2011-05-18T15:01:01Z",
    type: "some updated type",
    url: "some updated url"
  }
  @invalid_attrs %{country_id: nil, end_date: nil, start_date: nil, type: nil, url: nil}

  def fixture(:platform_terms_and_conditions) do
    {:ok, platform_terms_and_conditions} =
      Policy.create_platform_terms_and_conditions(@create_attrs)

    platform_terms_and_conditions
  end

  describe "index" do
    test "lists all platform_terms_and_conditions", %{conn: conn} do
      conn = get(conn, Routes.platform_terms_and_conditions_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Platform terms and conditions"
    end
  end

  describe "new platform_terms_and_conditions" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.platform_terms_and_conditions_path(conn, :new))
      assert html_response(conn, 200) =~ "New Platform terms and conditions"
    end
  end

  describe "create platform_terms_and_conditions" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.platform_terms_and_conditions_path(conn, :create),
          platform_terms_and_conditions: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.platform_terms_and_conditions_path(conn, :show, id)

      conn = get(conn, Routes.platform_terms_and_conditions_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Platform terms and conditions"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.platform_terms_and_conditions_path(conn, :create),
          platform_terms_and_conditions: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Platform terms and conditions"
    end
  end

  describe "edit platform_terms_and_conditions" do
    setup [:create_platform_terms_and_conditions]

    test "renders form for editing chosen platform_terms_and_conditions", %{
      conn: conn,
      platform_terms_and_conditions: platform_terms_and_conditions
    } do
      conn =
        get(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :edit, platform_terms_and_conditions)
        )

      assert html_response(conn, 200) =~ "Edit Platform terms and conditions"
    end
  end

  describe "update platform_terms_and_conditions" do
    setup [:create_platform_terms_and_conditions]

    test "redirects when data is valid", %{
      conn: conn,
      platform_terms_and_conditions: platform_terms_and_conditions
    } do
      conn =
        put(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :update, platform_terms_and_conditions),
          platform_terms_and_conditions: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.platform_terms_and_conditions_path(
                 conn,
                 :show,
                 platform_terms_and_conditions
               )

      conn =
        get(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :show, platform_terms_and_conditions)
        )

      assert html_response(conn, 200) =~ "some updated type"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      platform_terms_and_conditions: platform_terms_and_conditions
    } do
      conn =
        put(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :update, platform_terms_and_conditions),
          platform_terms_and_conditions: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Platform terms and conditions"
    end
  end

  describe "delete platform_terms_and_conditions" do
    setup [:create_platform_terms_and_conditions]

    test "deletes chosen platform_terms_and_conditions", %{
      conn: conn,
      platform_terms_and_conditions: platform_terms_and_conditions
    } do
      conn =
        delete(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :delete, platform_terms_and_conditions)
        )

      assert redirected_to(conn) == Routes.platform_terms_and_conditions_path(conn, :index)

      assert_error_sent 404, fn ->
        get(
          conn,
          Routes.platform_terms_and_conditions_path(conn, :show, platform_terms_and_conditions)
        )
      end
    end
  end

  defp create_platform_terms_and_conditions(_) do
    platform_terms_and_conditions = fixture(:platform_terms_and_conditions)
    {:ok, platform_terms_and_conditions: platform_terms_and_conditions}
  end
end
