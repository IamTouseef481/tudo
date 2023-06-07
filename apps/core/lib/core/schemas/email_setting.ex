defmodule Core.Schemas.EmailSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "email_settings" do
    field :slug, :string
    field :title, :string
    field :is_active, :boolean, default: false
    belongs_to :category, Core.Schemas.EmailCategory, type: :string
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(email_setting, attrs) do
    email_setting
    |> cast(attrs, [:slug, :title, :is_active, :category_id, :user_id])
    |> validate_required([:slug, :user_id])
  end
end
