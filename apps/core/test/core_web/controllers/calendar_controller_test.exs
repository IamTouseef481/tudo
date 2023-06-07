defmodule CoreWeb.CalendarControllerTest do
  use CoreWeb.ConnCase

  alias Core.Calendars

  @create_attrs %{schedule: %{}}
  @update_attrs %{schedule: %{}}
  @invalid_attrs %{schedule: nil}

  def fixture(:calendar) do
    {:ok, calendar} = Calendars.create_calendar(@create_attrs)
    calendar
  end

  describe "index" do
    test "lists all calendars", %{conn: conn} do
      conn = get(conn, Routes.calendar_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Calendars"
    end
  end

  describe "new calendar" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.calendar_path(conn, :new))
      assert html_response(conn, 200) =~ "New Calendar"
    end
  end

  describe "create calendar" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.calendar_path(conn, :create), calendar: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.calendar_path(conn, :show, id)

      conn = get(conn, Routes.calendar_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Calendar"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.calendar_path(conn, :create), calendar: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Calendar"
    end
  end

  describe "edit calendar" do
    setup [:create_calendar]

    test "renders form for editing chosen calendar", %{conn: conn, calendar: calendar} do
      conn = get(conn, Routes.calendar_path(conn, :edit, calendar))
      assert html_response(conn, 200) =~ "Edit Calendar"
    end
  end

  describe "update calendar" do
    setup [:create_calendar]

    test "redirects when data is valid", %{conn: conn, calendar: calendar} do
      conn = put(conn, Routes.calendar_path(conn, :update, calendar), calendar: @update_attrs)
      assert redirected_to(conn) == Routes.calendar_path(conn, :show, calendar)

      conn = get(conn, Routes.calendar_path(conn, :show, calendar))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, calendar: calendar} do
      conn = put(conn, Routes.calendar_path(conn, :update, calendar), calendar: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Calendar"
    end
  end

  describe "delete calendar" do
    setup [:create_calendar]

    test "deletes chosen calendar", %{conn: conn, calendar: calendar} do
      conn = delete(conn, Routes.calendar_path(conn, :delete, calendar))
      assert redirected_to(conn) == Routes.calendar_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.calendar_path(conn, :show, calendar))
      end
    end
  end

  defp create_calendar(_) do
    calendar = fixture(:calendar)
    {:ok, calendar: calendar}
  end
end
