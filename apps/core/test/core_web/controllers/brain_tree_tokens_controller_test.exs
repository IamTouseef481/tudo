defmodule CoreWeb.BrainTreeTokensControllerTest do
  use CoreWeb.ConnCase

  alias Core.Payments

  @create_attrs %{id: "some id", token: "some token"}
  @update_attrs %{id: "some updated id", token: "some updated token"}
  @invalid_attrs %{id: nil, token: nil}

  def fixture(:brain_tree_tokens) do
    {:ok, brain_tree_tokens} = Payments.create_brain_tree_tokens(@create_attrs)
    brain_tree_tokens
  end

  describe "index" do
    test "lists all brain_tree_tokens", %{conn: conn} do
      conn = get(conn, Routes.brain_tree_tokens_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Brain tree tokens"
    end
  end

  describe "new brain_tree_tokens" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.brain_tree_tokens_path(conn, :new))
      assert html_response(conn, 200) =~ "New Brain tree tokens"
    end
  end

  describe "create brain_tree_tokens" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.brain_tree_tokens_path(conn, :create), brain_tree_tokens: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.brain_tree_tokens_path(conn, :show, id)

      conn = get(conn, Routes.brain_tree_tokens_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Brain tree tokens"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.brain_tree_tokens_path(conn, :create), brain_tree_tokens: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Brain tree tokens"
    end
  end

  describe "edit brain_tree_tokens" do
    setup [:create_brain_tree_tokens]

    test "renders form for editing chosen brain_tree_tokens", %{
      conn: conn,
      brain_tree_tokens: brain_tree_tokens
    } do
      conn = get(conn, Routes.brain_tree_tokens_path(conn, :edit, brain_tree_tokens))
      assert html_response(conn, 200) =~ "Edit Brain tree tokens"
    end
  end

  describe "update brain_tree_tokens" do
    setup [:create_brain_tree_tokens]

    test "redirects when data is valid", %{conn: conn, brain_tree_tokens: brain_tree_tokens} do
      conn =
        put(conn, Routes.brain_tree_tokens_path(conn, :update, brain_tree_tokens),
          brain_tree_tokens: @update_attrs
        )

      assert redirected_to(conn) == Routes.brain_tree_tokens_path(conn, :show, brain_tree_tokens)

      conn = get(conn, Routes.brain_tree_tokens_path(conn, :show, brain_tree_tokens))
      assert html_response(conn, 200) =~ "some updated id"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      brain_tree_tokens: brain_tree_tokens
    } do
      conn =
        put(conn, Routes.brain_tree_tokens_path(conn, :update, brain_tree_tokens),
          brain_tree_tokens: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Brain tree tokens"
    end
  end

  describe "delete brain_tree_tokens" do
    setup [:create_brain_tree_tokens]

    test "deletes chosen brain_tree_tokens", %{conn: conn, brain_tree_tokens: brain_tree_tokens} do
      conn = delete(conn, Routes.brain_tree_tokens_path(conn, :delete, brain_tree_tokens))
      assert redirected_to(conn) == Routes.brain_tree_tokens_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.brain_tree_tokens_path(conn, :show, brain_tree_tokens))
      end
    end
  end

  defp create_brain_tree_tokens(_) do
    brain_tree_tokens = fixture(:brain_tree_tokens)
    {:ok, brain_tree_tokens: brain_tree_tokens}
  end
end
