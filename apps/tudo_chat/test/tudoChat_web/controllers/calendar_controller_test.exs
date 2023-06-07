defmodule TudoChatWeb.CalendarControllerTest do
  use TudoChatWeb.ConnCase

  alias TudoChat.Calendars

  @create_attrs %{
    alarm_sound: "some alarm_sound",
    all_day: true,
    calendar_desc: "some calendar_desc",
    calendar_title: "some calendar_title",
    duration: "2010-04-17T14:00:00Z",
    end_date: "2010-04-17T14:00:00Z",
    number_of_occurances: 42,
    recurring: "some recurring",
    recurring_interval: "some recurring_interval",
    reminders: %{},
    show_us: "some show_us",
    snooz: true,
    start_date: "2010-04-17T14:00:00Z"
  }
  @update_attrs %{
    alarm_sound: "some updated alarm_sound",
    all_day: false,
    calendar_desc: "some updated calendar_desc",
    calendar_title: "some updated calendar_title",
    duration: "2011-05-18T15:01:01Z",
    end_date: "2011-05-18T15:01:01Z",
    number_of_occurances: 43,
    recurring: "some updated recurring",
    recurring_interval: "some updated recurring_interval",
    reminders: %{},
    show_us: "some updated show_us",
    snooz: false,
    start_date: "2011-05-18T15:01:01Z"
  }
  @invalid_attrs %{
    alarm_sound: nil,
    all_day: nil,
    calendar_desc: nil,
    calendar_title: nil,
    duration: nil,
    end_date: nil,
    number_of_occurances: nil,
    recurring: nil,
    recurring_interval: nil,
    reminders: nil,
    show_us: nil,
    snooz: nil,
    start_date: nil
  }

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
      assert html_response(conn, 200) =~ "some updated alarm_sound"
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
