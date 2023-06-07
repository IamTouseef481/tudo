defmodule Core.Schemas.BranchService do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "branch_services" do
    field :is_active, :boolean, default: false
    field :auto_assign, :boolean, default: false
    belongs_to :branch, Core.Schemas.Branch
    belongs_to :country_service, Core.Schemas.CountryService
    belongs_to :service_type, Core.Schemas.ServiceType, type: :string

    timestamps()
  end

  @doc false
  def changeset(branch_service, attrs) do
    branch_service
    |> cast(attrs, [:country_service_id, :branch_id, :service_type_id, :is_active, :auto_assign])
    |> validate_required([:country_service_id, :branch_id, :is_active])
  end
end
