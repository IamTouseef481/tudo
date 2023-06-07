defmodule TudoChat.Messages.JobStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "job_statuses" do
    field :description, :string
    field :id, :string, primary_key: true
  end

  @doc false
  def changeset(job_status, attrs) do
    job_status
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
