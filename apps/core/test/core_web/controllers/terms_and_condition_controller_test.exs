defmodule CoreWeb.TermsAndConditionControllerTest do
  use CoreWeb.ConnCase

  alias Core.Business

  @create_attrs %{
    end_date: "2010-04-17T14:00:00Z",
    start_date: "2010-04-17T14:00:00Z",
    text: "some text"
  }
  @update_attrs %{
    end_date: "2011-05-18T15:01:01Z",
    start_date: "2011-05-18T15:01:01Z",
    text: "some updated text"
  }
  @invalid_attrs %{end_date: nil, start_date: nil, text: nil}

  def fixture(:terms_and_condition) do
    {:ok, terms_and_condition} = Business.create_terms_and_condition(@create_attrs)
    terms_and_condition
  end

  describe "index" do
    test "lists all terms_and_conditions", %{conn: conn} do
      conn = get(conn, Routes.terms_and_condition_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Terms and conditions"
    end
  end

  describe "new terms_and_condition" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.terms_and_condition_path(conn, :new))
      assert html_response(conn, 200) =~ "New Terms and condition"
    end
  end

  describe "create terms_and_condition" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.terms_and_condition_path(conn, :create),
          terms_and_condition: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.terms_and_condition_path(conn, :show, id)

      conn = get(conn, Routes.terms_and_condition_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Terms and condition"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.terms_and_condition_path(conn, :create),
          terms_and_condition: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Terms and condition"
    end
  end

  describe "edit terms_and_condition" do
    setup [:create_terms_and_condition]

    test "renders form for editing chosen terms_and_condition", %{
      conn: conn,
      terms_and_condition: terms_and_condition
    } do
      conn = get(conn, Routes.terms_and_condition_path(conn, :edit, terms_and_condition))
      assert html_response(conn, 200) =~ "Edit Terms and condition"
    end
  end

  describe "update terms_and_condition" do
    setup [:create_terms_and_condition]

    test "redirects when data is valid", %{conn: conn, terms_and_condition: terms_and_condition} do
      conn =
        put(conn, Routes.terms_and_condition_path(conn, :update, terms_and_condition),
          terms_and_condition: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.terms_and_condition_path(conn, :show, terms_and_condition)

      conn = get(conn, Routes.terms_and_condition_path(conn, :show, terms_and_condition))
      assert html_response(conn, 200) =~ "some updated text"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      terms_and_condition: terms_and_condition
    } do
      conn =
        put(conn, Routes.terms_and_condition_path(conn, :update, terms_and_condition),
          terms_and_condition: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Terms and condition"
    end
  end

  describe "delete terms_and_condition" do
    setup [:create_terms_and_condition]

    test "deletes chosen terms_and_condition", %{
      conn: conn,
      terms_and_condition: terms_and_condition
    } do
      conn = delete(conn, Routes.terms_and_condition_path(conn, :delete, terms_and_condition))
      assert redirected_to(conn) == Routes.terms_and_condition_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.terms_and_condition_path(conn, :show, terms_and_condition))
      end
    end
  end

  defp create_terms_and_condition(_) do
    terms_and_condition = fixture(:terms_and_condition)
    {:ok, terms_and_condition: terms_and_condition}
  end
end
