defmodule Core.Schemas.Holiday do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "holidays" do
    field :title, :string
    field :type, :string
    field :description, :string
    field :from, :utc_datetime
    field :purpose, :string
    field :to, :utc_datetime
    belongs_to :branch, Core.Schemas.Branch
    #    belongs_to :business, Core.Schemas.Business

    timestamps()
  end

  @doc false
  def changeset(holiday, attrs) do
    holiday
    |> cast(attrs, [
      :branch_id,
      #      :business_id,
      :title,
      :type,
      :description,
      :from,
      :to,
      :purpose
    ])
    |> validate_required([:title, :from, :to])
  end
end
