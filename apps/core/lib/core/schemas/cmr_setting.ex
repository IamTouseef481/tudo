defmodule Core.Schemas.CMRSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cmr_settings" do
    field :title, :string
    field :slug, :string
    field :type, :string
    field :fields, {:array, :map}
    belongs_to :user, Core.Schemas.User
    belongs_to :employee, Core.Schemas.Employee
    #    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(cmr_settings, attrs) do
    cmr_settings
    |> cast(attrs, [:user_id, :employee_id, :slug, :title, :type, :fields])
    |> validate_required([:slug, :fields])
  end
end
