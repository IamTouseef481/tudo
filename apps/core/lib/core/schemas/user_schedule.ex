defmodule Core.Schemas.UserSchedule do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.User

  schema "user_schedules" do
    field :schedule, :map
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_schedule, attrs) do
    user_schedule
    |> cast(attrs, [:user_id, :schedule])
    |> validate_required([:user_id, :schedule])
  end
end
