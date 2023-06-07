defmodule Core.Repo.Migrations.AlterTableBranchAddFieldOutdoorStickerPdf do
  use Ecto.Migration

  def change do
    alter table(:branches) do
      add :outdoor_sticker_pdf, :string
    end
  end
end
