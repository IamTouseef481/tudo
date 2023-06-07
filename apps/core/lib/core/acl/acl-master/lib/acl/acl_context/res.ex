# credo:disable-for-this-file
defmodule Acl.AclContext.Res do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "acl_res" do
    field :parent, :string
    field :res, :string
    has_many :rules, Acl.AclContext.Rule, foreign_key: :res_id
    timestamps()
  end

  @doc false
  def changeset(res, attrs) do
    res
    |> cast(attrs, [:res, :parent])
    |> validate_required([:res])
  end
end
