defmodule Core.Schemas.JobCategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "job_categories" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(job_category, attrs) do
    job_category
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
