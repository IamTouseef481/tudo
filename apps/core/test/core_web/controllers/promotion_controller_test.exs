defmodule CoreWeb.PromotionControllerTest do
  use CoreWeb.ConnCase

  alias Core.Promotions

  @create_attrs %{
    begin_date: "2010-04-17T14:00:00Z",
    description: "some description",
    end_date: "2010-04-17T14:00:00Z",
    photos: %{},
    title: "some title"
  }
  @update_attrs %{
    begin_date: "2011-05-18T15:01:01Z",
    description: "some updated description",
    end_date: "2011-05-18T15:01:01Z",
    photos: %{},
    title: "some updated title"
  }
  @invalid_attrs %{begin_date: nil, description: nil, end_date: nil, photos: nil, title: nil}

  def fixture(:promotion) do
    {:ok, promotion} = Promotions.create_promotion(@create_attrs)
    promotion
  end

  describe "index" do
    test "lists all promotions", %{conn: conn} do
      conn = get(conn, Routes.promotion_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Promotions"
    end
  end

  describe "new promotion" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.promotion_path(conn, :new))
      assert html_response(conn, 200) =~ "New Promotion"
    end
  end

  describe "create promotion" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.promotion_path(conn, :create), promotion: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.promotion_path(conn, :show, id)

      conn = get(conn, Routes.promotion_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Promotion"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.promotion_path(conn, :create), promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Promotion"
    end
  end

  describe "edit promotion" do
    setup [:create_promotion]

    test "renders form for editing chosen promotion", %{conn: conn, promotion: promotion} do
      conn = get(conn, Routes.promotion_path(conn, :edit, promotion))
      assert html_response(conn, 200) =~ "Edit Promotion"
    end
  end

  describe "update promotion" do
    setup [:create_promotion]

    test "redirects when data is valid", %{conn: conn, promotion: promotion} do
      conn = put(conn, Routes.promotion_path(conn, :update, promotion), promotion: @update_attrs)
      assert redirected_to(conn) == Routes.promotion_path(conn, :show, promotion)

      conn = get(conn, Routes.promotion_path(conn, :show, promotion))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, promotion: promotion} do
      conn = put(conn, Routes.promotion_path(conn, :update, promotion), promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Promotion"
    end
  end

  describe "delete promotion" do
    setup [:create_promotion]

    test "deletes chosen promotion", %{conn: conn, promotion: promotion} do
      conn = delete(conn, Routes.promotion_path(conn, :delete, promotion))
      assert redirected_to(conn) == Routes.promotion_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.promotion_path(conn, :show, promotion))
      end
    end
  end

  defp create_promotion(_) do
    promotion = fixture(:promotion)
    {:ok, promotion: promotion}
  end
end
