defmodule Core.Schemas.BiddingJob do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.BidProposal
  alias Core.Schemas.ServiceType

  schema "bidding_jobs" do
    field :arrive_at, :utc_datetime
    field :cmr_id, :integer
    field :country_service_id, :integer
    field :description, :string
    field :expected_work_duration, :time
    field :gallery, {:array, :map}
    field :location_dest, Geo.PostGIS.Geometry
    field :job_address, :string
    field :posted_at, :utc_datetime
    field :accepted, :boolean, default: false
    field :expired, :boolean, default: false
    field :questions, {:array, :string}
    field :title, :string
    field :dynamic_fields, :map
    belongs_to :service_type, ServiceType, type: :string
    belongs_to :job_category, Core.Schemas.JobCategory, type: :string
    has_many :proposals, BidProposal

    timestamps()
  end

  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, [
      :title,
      :description,
      :gallery,
      :country_service_id,
      :service_type_id,
      :location_dest,
      :job_address,
      :arrive_at,
      :expected_work_duration,
      :dynamic_fields,
      :posted_at,
      :accepted,
      :expired,
      :cmr_id,
      :questions,
      :job_category_id
    ])
    |> validate_required([:title, :country_service_id, :location_dest, :posted_at, :cmr_id])
  end
end
