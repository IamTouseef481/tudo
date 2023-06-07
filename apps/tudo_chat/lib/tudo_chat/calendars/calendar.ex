defmodule TudoChat.Calendars.Calendar do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendars" do
    field :alarm_sound, :string
    field :all_day, :boolean, default: false
    field :calendar_desc, :string
    field :calendar_title, :string
    field :duration, :utc_datetime
    field :end_date, :utc_datetime
    field :number_of_occurances, :integer
    field :recurring, :string
    field :recurring_interval, :string
    field :reminders, :map
    field :show_us, :string
    field :snooz, :boolean, default: false
    field :start_date, :utc_datetime
    field :group_id, :id
    field :created_by_id, :id
    field :last_updated_by_id, :id

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [
      :calendar_title,
      :calendar_desc,
      :all_day,
      :start_date,
      :duration,
      :recurring,
      :recurring_interval,
      :number_of_occurances,
      :end_date,
      :reminders,
      :alarm_sound,
      :snooz,
      :show_us
    ])
    |> validate_required([
      :calendar_title,
      :calendar_desc,
      :all_day,
      :start_date,
      :duration,
      :recurring,
      :recurring_interval,
      :number_of_occurances,
      :end_date,
      :reminders,
      :alarm_sound,
      :snooz,
      :show_us
    ])
  end
end
