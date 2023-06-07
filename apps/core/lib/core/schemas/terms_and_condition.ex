defmodule Core.Schemas.TermsAndCondition do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "terms_and_conditions" do
    field :end_date, :utc_datetime
    field :start_date, :utc_datetime
    field :text, :string

    timestamps()
  end

  @doc false
  def changeset(terms_and_condition, attrs) do
    terms_and_condition
    |> cast(attrs, [:text, :start_date, :end_date])
    |> validate_required([:text, :start_date, :end_date])
  end
end
