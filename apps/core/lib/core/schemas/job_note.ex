defmodule Core.Schemas.JobNote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_notes" do
    field :note, :string
    field :note_type, :string
    field :user_id, :integer
    field :branch_id, :integer
    belongs_to :job, Core.Schemas.Job, type: :integer

    timestamps()
  end

  @doc false
  def changeset(job_note, attrs) do
    job_note
    |> cast(attrs, [
      :note,
      :note_type,
      :user_id,
      :job_id,
      :branch_id
    ])
    |> validate_required([:note, :note_type, :user_id, :job_id, :branch_id])
    |> unique_constraint([:job_id, :note_type], name: :job_notes_note_type_job_id_index)
  end
end
