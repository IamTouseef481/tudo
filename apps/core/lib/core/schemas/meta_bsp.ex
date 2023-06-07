defmodule Core.Schemas.MetaBSP do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "meta_bsp" do
    field :statistics, :map
    field :type, :string
    field :terms_accepted, :boolean, default: true
    belongs_to :employee, Core.Schemas.Employee
    belongs_to :user, Core.Schemas.User
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(meta, attrs) do
    meta
    |> cast(attrs, [:employee_id, :user_id, :branch_id, :type, :statistics, :terms_accepted])
    |> validate_required([:type, :statistics])
  end
end
