defmodule TudoChat.Channels.Channel do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :name, :string
    field :desc, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :desc, :status])
    |> validate_required([:name, :desc, :status])
    |> unique_constraint(:name)
  end
end
