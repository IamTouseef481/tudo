defmodule Stitch.Repo.Migrations.AddProfileImageUrlToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :profile_image_url, :string
    end
  end
end
