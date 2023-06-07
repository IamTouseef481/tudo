defmodule Core.Schemas.Calendar do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "calendars" do
    field :schedule, :map
    belongs_to :user, Core.Schemas.User
    belongs_to :employee, Core.Schemas.Employee
    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:schedule, :user_id, :employee_id])
  end
end
