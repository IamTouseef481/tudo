defmodule CoreWeb.JobControllerTest do
  use CoreWeb.ConnCase

  alias Core.Jobs

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:job_category) do
    {:ok, job_category} = Jobs.create_job_category(@create_attrs)
    job_category
  end

  describe "index" do
    test "lists all job_categories", %{conn: conn} do
      conn = get(conn, Routes.job_category_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Job categories"
    end
  end

  describe "new job_category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.job_category_path(conn, :new))
      assert html_response(conn, 200) =~ "New Job category"
    end
  end

  describe "create job_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.job_category_path(conn, :create), job_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.job_category_path(conn, :show, id)

      conn = get(conn, Routes.job_category_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Job category"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.job_category_path(conn, :create), job_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Job category"
    end
  end

  describe "edit job_category" do
    setup [:create_job_category]

    test "renders form for editing chosen job_category", %{conn: conn, job_category: job_category} do
      conn = get(conn, Routes.job_category_path(conn, :edit, job_category))
      assert html_response(conn, 200) =~ "Edit Job category"
    end
  end

  describe "update job_category" do
    setup [:create_job_category]

    test "redirects when data is valid", %{conn: conn, job_category: job_category} do
      conn =
        put(conn, Routes.job_category_path(conn, :update, job_category),
          job_category: @update_attrs
        )

      assert redirected_to(conn) == Routes.job_category_path(conn, :show, job_category)

      conn = get(conn, Routes.job_category_path(conn, :show, job_category))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, job_category: job_category} do
      conn =
        put(conn, Routes.job_category_path(conn, :update, job_category),
          job_category: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Job category"
    end
  end

  describe "delete job_category" do
    setup [:create_job_category]

    test "deletes chosen job_category", %{conn: conn, job_category: job_category} do
      conn = delete(conn, Routes.job_category_path(conn, :delete, job_category))
      assert redirected_to(conn) == Routes.job_category_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.job_category_path(conn, :show, job_category))
      end
    end
  end

  defp create_job_category(_) do
    job_category = fixture(:job_category)
    {:ok, job_category: job_category}
  end
end
