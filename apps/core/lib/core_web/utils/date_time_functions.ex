defmodule CoreWeb.Utils.DateTimeFunctions do
  @moduledoc false

  def day_name(datetime, is_atom \\ true) do
    day_name = datetime |> Timex.weekday() |> Timex.day_name() |> String.downcase()
    if is_atom, do: day_name |> String.to_atom(), else: day_name
  end

  def time_to_datetime(time, date \\ Timex.beginning_of_day(Timex.now()), add_date \\ true) do
    time = if is_bitstring(time), do: Time.from_iso8601(time), else: {:ok, time}
    date = if Timex.is_valid?(date), do: {:ok, date}, else: Time.from_iso8601(date)
    {:ok, date} = date

    case time do
      {:ok, time} when add_date -> Timex.add(date, Timex.Duration.from_time(time))
      {:ok, time} -> time
      _ -> {:error, ["Unable to convert String to Time format"]}
    end
  end

  def is_in_between(from, until, value) do
    value in Timex.Interval.new(
      from: from,
      left_open: true,
      right_open: true,
      until: until
    )
  end

  def convert_utc_time_to_local_time(time \\ DateTime.utc_now()) do
    if Timex.is_valid?(time) do
      # difference in milliseconds
      dif = Application.get_env(:core, :utc_difference)
      # difference in microseconds
      dif = dif * 1000
      Timex.shift(time, microseconds: dif)
    else
      time
    end
  end

  def add_zero_before_minutes(minutes) do
    if minutes < 10, do: "0#{minutes}", else: minutes
  end

  def convert_seconds_to_time_string(time_in_seconds) do
    seconds = rem(time_in_seconds, 60)
    min_hours = trunc((time_in_seconds - seconds) / 60)
    minutes = rem(min_hours, 60)
    hours = trunc((min_hours - minutes) / 60)
    Enum.map_join([hours, minutes, seconds], ":", &if(&1 < 10, do: "0#{&1}", else: to_string(&1)))
  end

  def reformat_datetime_for_emails(datetime \\ DateTime.utc_now()) do
    if Timex.is_valid?(datetime) do
      day_name = datetime |> Timex.weekday() |> Timex.day_shortname()
      {{year, month, date}, {hours, minutes, _seconds}} = Timex.to_erl(datetime)
      minutes = CoreWeb.Utils.DateTimeFunctions.add_zero_before_minutes(minutes)
      month_name = Timex.month_name(month)

      date =
        cond do
          date in [1, 21, 31] -> "#{date}st"
          date in [2, 22] -> "#{date}nd"
          date in [3, 23] -> "#{date}rd"
          true -> "#{date}th"
        end

      #      conversion 24 hour to 12 hour manually
      #      {hours, format} = cond do
      #        hours < 10 -> {"0#{hours}", "AM"}
      #        hours in [10, 11] -> {hours, "AM"}
      #        hours == 12 -> {hours, "PM"}
      #        hours > 12 -> if rem(hours, 12) < 10, do: {"0#{rem(hours, 12)}", "PM"}, else: {rem(hours, 12), "PM"}
      #        true -> hours
      #      end

      #       conversion 24 hour to 12 hour through Timex function
      {hours, format} =
        case Timex.Time.to_12hour_clock(hours) do
          {hours, :am} -> if hours < 10, do: {"0#{hours}", "AM"}, else: {hours, "AM"}
          {hours, :pm} -> if hours < 10, do: {"0#{hours}", "PM"}, else: {hours, "PM"}
          _ -> {hours, ""}
        end

      "#{day_name}, #{month_name} #{date}, #{year} #{hours}:#{minutes} #{format}"
    else
      datetime
    end
  end

  def convert_utc_datatime_to_string(datatime) do
    # utc_diff = Application.get_env(:core, :utc_difference)
    # |> convert_seconds_to_time_string()
    # |> String.slice(0..-4)

    datetime =
      datatime
      |> to_string()
      |> String.replace(" ", "T")
      |> String.replace("Z", "")

    # datetime <> "-" <> utc_diff
    datetime <> "+" <> "00:00"
  end
end
