# credo:disable-for-this-file
defmodule Acl.AclContext.Rule do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "acl_rules" do
    field :condition, :integer, default: 1
    field :where_cond, :string, default: nil
    field :where_value, :string, default: nil
    field :where_field, :string, default: nil
    field :permission, :integer, default: 1
    field :action, :string, default: nil
    field :role, :string, primary_key: true
    belongs_to :res, Acl.AclContext.Res, references: :id, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(rule, attrs, res) do
    rule
    |> cast(attrs, [:action, :permission, :role, :condition])
    |> put_assoc(:res, res)
    |> validate_required([:res, :role])
  end

  def u_changeset(rule, attrs) do
    rule
    |> cast(attrs, [:action, :permission, :role, :condition, :res_id])
    |> validate_required([:res, :role])
  end
end
