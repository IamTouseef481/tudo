defmodule Stitch.Repo.Migrations.AddSlackImportIdToMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:slack_import_id, :string, null: true)
    end
  end
end
