defmodule Core.Schemas.SearchBSP do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_bsp" do
    field :service_id, :integer
    field :arrive_at, :utc_datetime
    field :location, :map
    field :service_status_id, :string, default: "active"
    field :rating, :float, default: 0.0
    field :rating_count, :integer, default: 0
  end

  @doc false
  def changeset(search_bsp, attrs) do
    search_bsp
    |> cast(attrs, [
      :service_id,
      :arrive_at,
      :location,
      :service_status_id,
      :rating,
      :rating_count
    ])
  end
end
