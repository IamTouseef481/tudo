defmodule Core.Schemas.MenuRole do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "menu_roles" do
    field :doc_order, :integer
    field :menu_order, :integer
    #    field :nemu_id, :id
    belongs_to :menu, Core.Schemas.Menu
    #    field :acl_role_id, :id
    belongs_to :acl_role, Core.Acl.AclRole, type: :string

    timestamps()
  end

  @doc false
  def changeset(menu_role, attrs) do
    menu_role
    |> cast(attrs, [:acl_role_id, :menu_id, :doc_order, :menu_order])
    |> validate_required([:acl_role_id, :menu_id, :doc_order, :menu_order])
  end
end
