defmodule Core.Schemas.GoogleCalender do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Job}

  @all_fields [
    :cmr_event_id,
    :bsp_event_id,
    :job_id
  ]

  schema "google_calenders" do
    field :cmr_event_id, :string
    field :bsp_event_id, :string

    belongs_to :job, Job, type: :integer

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, @all_fields)
    |> validate_required([:job_id])
  end
end
