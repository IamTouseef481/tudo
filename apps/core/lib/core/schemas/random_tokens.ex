defmodule Core.Schemas.RandomTokens do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{User, UserInstalls}

  schema "random_tokens" do
    field :app, :string, default: "mobile"
    field :day_count, :integer
    field :expired_at, :utc_datetime
    field :history, {:array, :string}
    field :hour_count, :integer
    field :login, :string
    field :min_count, :integer
    field :purpose, :string
    field :token, :integer
    field :expired, :boolean
    #    field :device_id, :id
    belongs_to :device, UserInstalls
    #    field :expired_by, :id
    belongs_to :expired_by, User

    timestamps()
  end

  @doc false
  def changeset(random_tokens, %{device_id: _device_id} = attrs) do
    random_tokens
    |> cast(attrs, [
      :device_id,
      :expired_by_id,
      :token,
      :purpose,
      :login,
      :app,
      :history,
      :min_count,
      :hour_count,
      :day_count,
      :expired_at,
      :expired
    ])
    |> validate_required([
      :device_id,
      :token,
      :purpose,
      :login,
      :app,
      :min_count,
      :hour_count,
      :day_count
    ])
  end

  @doc false
  def changeset(random_tokens, attrs) do
    random_tokens
    |> cast(attrs, [
      :device_id,
      :expired_by_id,
      :token,
      :purpose,
      :login,
      :app,
      :history,
      :min_count,
      :hour_count,
      :day_count,
      :expired_at,
      :expired
    ])
    |> validate_required([:token, :purpose, :login, :app, :min_count, :hour_count, :day_count])
  end
end
