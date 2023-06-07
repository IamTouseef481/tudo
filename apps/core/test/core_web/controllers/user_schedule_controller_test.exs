defmodule CoreWeb.UserScheduleControllerTest do
  use CoreWeb.ConnCase

  alias Core.Schedules

  @create_attrs %{schedule: %{}}
  @update_attrs %{schedule: %{}}
  @invalid_attrs %{schedule: nil}

  def fixture(:user_schedule) do
    {:ok, user_schedule} = Schedules.create_user_schedule(@create_attrs)
    user_schedule
  end

  describe "index" do
    test "lists all user_schedules", %{conn: conn} do
      conn = get(conn, Routes.user_schedule_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing User schedules"
    end
  end

  describe "new user_schedule" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_schedule_path(conn, :new))
      assert html_response(conn, 200) =~ "New User schedule"
    end
  end

  describe "create user_schedule" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_schedule_path(conn, :create), user_schedule: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_schedule_path(conn, :show, id)

      conn = get(conn, Routes.user_schedule_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User schedule"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_schedule_path(conn, :create), user_schedule: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User schedule"
    end
  end

  describe "edit user_schedule" do
    setup [:create_user_schedule]

    test "renders form for editing chosen user_schedule", %{
      conn: conn,
      user_schedule: user_schedule
    } do
      conn = get(conn, Routes.user_schedule_path(conn, :edit, user_schedule))
      assert html_response(conn, 200) =~ "Edit User schedule"
    end
  end

  describe "update user_schedule" do
    setup [:create_user_schedule]

    test "redirects when data is valid", %{conn: conn, user_schedule: user_schedule} do
      conn =
        put(conn, Routes.user_schedule_path(conn, :update, user_schedule),
          user_schedule: @update_attrs
        )

      assert redirected_to(conn) == Routes.user_schedule_path(conn, :show, user_schedule)

      conn = get(conn, Routes.user_schedule_path(conn, :show, user_schedule))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user_schedule: user_schedule} do
      conn =
        put(conn, Routes.user_schedule_path(conn, :update, user_schedule),
          user_schedule: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit User schedule"
    end
  end

  describe "delete user_schedule" do
    setup [:create_user_schedule]

    test "deletes chosen user_schedule", %{conn: conn, user_schedule: user_schedule} do
      conn = delete(conn, Routes.user_schedule_path(conn, :delete, user_schedule))
      assert redirected_to(conn) == Routes.user_schedule_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_schedule_path(conn, :show, user_schedule))
      end
    end
  end

  defp create_user_schedule(_) do
    user_schedule = fixture(:user_schedule)
    {:ok, user_schedule: user_schedule}
  end
end
