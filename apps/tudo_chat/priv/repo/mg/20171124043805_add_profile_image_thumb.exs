defmodule Stitch.Repo.Migrations.AddProfileImageThumb do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :profile_image_thumb_url, :string, default: nil, null: true
    end
  end
end
