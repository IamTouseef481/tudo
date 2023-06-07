defmodule Core.Schemas.Order do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :location_dest, Geo.PostGIS.Geometry
    field :location_src, Geo.PostGIS.Geometry
    field :rating, :float
    field :arrive_at, :utc_datetime
    field :picked_at, :utc_datetime
    field :src_to_dest_distance, :float
    field :cmr_to_bsp_comment, :map
    field :bsp_to_cmr_comment, :map
    field :est_work_duration, :utc_datetime
    field :instruction_to_rider, :string
    field :est_delivery_sec, :string
    field :chat_group_id, :integer
    field :description, :string
    field :authorization_id, :string

    belongs_to :user, Core.Schemas.User
    belongs_to :status, Core.Schemas.JobStatus, type: :string
    belongs_to :payment_method, Core.Schemas.PaymentMethod, type: :string

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :user_id,
      :location_dest,
      :location_src,
      :rating,
      :arrive_at,
      :picked_at,
      :status_id,
      :src_to_dest_distance,
      :cmr_to_bsp_comment,
      :bsp_to_cmr_comment,
      :est_work_duration,
      :instruction_to_rider,
      :chat_group_id,
      :payment_method_id,
      :description,
      :est_delivery_sec,
      :authorization_id
    ])
  end
end
