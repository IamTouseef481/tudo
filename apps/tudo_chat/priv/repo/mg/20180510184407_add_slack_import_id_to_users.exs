defmodule Stitch.Repo.Migrations.AddSlackImportIdToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:slack_import_id, :string, null: true)
    end
  end
end
