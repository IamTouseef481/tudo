defmodule TudoChat.Calls.CallMeta do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Calls.Call

  schema "calls_meta" do
    field :participant_id, :integer
    field :call_start_time, :utc_datetime
    field :call_end_time, :utc_datetime
    field :admin, :boolean, default: false
    field :status, :string
    field :call_duration, :time
    belongs_to :call, Call

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :participant_id,
      :call_start_time,
      :call_end_time,
      :admin,
      :status,
      :call_duration,
      :call_id
    ])
    |> validate_required([:call_id])
  end
end
