# credo:disable-for-this-file
defmodule Acl.AclContext.Role do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:role, :string, autogenerate: false}

  schema "acl_roles" do
    field :parent, :string
    # field :role, :string, primary_key: true
    has_many :rules, Acl.AclContext.Rule, foreign_key: :role
    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:role, :parent])
    |> validate_required([:role])
  end
end
