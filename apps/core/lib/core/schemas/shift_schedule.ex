defmodule Core.Schemas.ShiftSchedule do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "shift_schedules" do
    field :id, :string, primary_key: true
    field :name, :string
    field :start_time, :time
    field :end_time, :time

    timestamps()
  end

  @doc false
  def changeset(shift_schedule, attrs) do
    shift_schedule
    |> cast(attrs, [:id, :name, :start_time, :end_time])
    |> validate_required([:id, :name, :start_time, :end_time])
  end
end
