defmodule Core.Schemas.MetaCMR do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "meta_cmr" do
    field :statistics, :map
    field :type, :string
    field :terms_accepted, :boolean, default: true
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(meta_cmr, attrs) do
    meta_cmr
    |> cast(attrs, [:user_id, :type, :statistics, :terms_accepted])
    |> validate_required([:type, :statistics])
  end
end
