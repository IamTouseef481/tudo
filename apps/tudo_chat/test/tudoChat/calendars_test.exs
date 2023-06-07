defmodule TudoChat.CalendarsTest do
  use TudoChat.DataCase

  alias TudoChat.Calendars

  describe "calendars" do
    alias TudoChat.Calendars.Calendar

    @valid_attrs %{
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

    def calendar_fixture(attrs \\ %{}) do
      {:ok, calendar} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Calendars.create_calendar()

      calendar
    end

    test "list_calendars/0 returns all calendars" do
      calendar = calendar_fixture()
      assert Calendars.list_calendars() == [calendar]
    end

    test "get_calendar!/1 returns the calendar with given id" do
      calendar = calendar_fixture()
      assert Calendars.get_calendar!(calendar.id) == calendar
    end

    test "create_calendar/1 with valid data creates a calendar" do
      assert {:ok, %Calendar{} = calendar} = Calendars.create_calendar(@valid_attrs)
      assert calendar.alarm_sound == "some alarm_sound"
      assert calendar.all_day == true
      assert calendar.calendar_desc == "some calendar_desc"
      assert calendar.calendar_title == "some calendar_title"
      assert calendar.duration == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert calendar.end_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert calendar.number_of_occurances == 42
      assert calendar.recurring == "some recurring"
      assert calendar.recurring_interval == "some recurring_interval"
      assert calendar.reminders == %{}
      assert calendar.show_us == "some show_us"
      assert calendar.snooz == true
      assert calendar.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_calendar/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_calendar(@invalid_attrs)
    end

    test "update_calendar/2 with valid data updates the calendar" do
      calendar = calendar_fixture()
      assert {:ok, %Calendar{} = calendar} = Calendars.update_calendar(calendar, @update_attrs)
      assert calendar.alarm_sound == "some updated alarm_sound"
      assert calendar.all_day == false
      assert calendar.calendar_desc == "some updated calendar_desc"
      assert calendar.calendar_title == "some updated calendar_title"
      assert calendar.duration == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert calendar.end_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert calendar.number_of_occurances == 43
      assert calendar.recurring == "some updated recurring"
      assert calendar.recurring_interval == "some updated recurring_interval"
      assert calendar.reminders == %{}
      assert calendar.show_us == "some updated show_us"
      assert calendar.snooz == false
      assert calendar.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_calendar/2 with invalid data returns error changeset" do
      calendar = calendar_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendars.update_calendar(calendar, @invalid_attrs)
      assert calendar == Calendars.get_calendar!(calendar.id)
    end

    test "delete_calendar/1 deletes the calendar" do
      calendar = calendar_fixture()
      assert {:ok, %Calendar{}} = Calendars.delete_calendar(calendar)
      assert_raise Ecto.NoResultsError, fn -> Calendars.get_calendar!(calendar.id) end
    end

    test "change_calendar/1 returns a calendar changeset" do
      calendar = calendar_fixture()
      assert %Ecto.Changeset{} = Calendars.change_calendar(calendar)
    end
  end
end
