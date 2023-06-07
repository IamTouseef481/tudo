defmodule TudoChat.Settings.Setting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "settings" do
    field :fields, :map
    field :slug, :string
    field :title, :string
    field :type, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:title, :slug, :type, :user_id, :fields])
    |> validate_required([:slug, :user_id, :fields])
  end
end
