# credo:disable-for-this-file
defmodule Core.Acl.AclRole do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "acl_roles" do
    field :id, :string, primary_key: true
    field :parent, :string

    timestamps()
  end

  @doc false
  def changeset(acl_role, attrs) do
    acl_role
    |> cast(attrs, [:id, :parent])
    |> validate_required([:id, :parent])
  end
end
