defmodule Stitch.Repo.Migrations.AddInformationToTeams do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:ehr, :string)
      add(:industry, :string)
      add(:size, :string)
    end
  end
end
