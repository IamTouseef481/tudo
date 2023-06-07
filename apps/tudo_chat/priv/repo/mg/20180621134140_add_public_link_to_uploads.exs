defmodule Stitch.Repo.Migrations.AddPublicLinkToUploads do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add(:public_link, :text, null: true)
    end
  end
end
