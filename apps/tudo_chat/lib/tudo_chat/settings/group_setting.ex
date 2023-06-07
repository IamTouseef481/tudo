defmodule TudoChat.Settings.GroupSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "group_settings" do
    field :fields, :map
    field :slug, :string
    field :title, :string
    field :user_id, :integer
    belongs_to :group, TudoChat.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(group_setting, attrs) do
    group_setting
    |> cast(attrs, [:title, :slug, :fields, :user_id, :group_id])
    |> validate_required([:slug, :user_id, :group_id, :fields])
  end
end
