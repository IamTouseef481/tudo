defmodule Stitch.Repo.Migrations.AddOnboardedToTeams do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:onboarded, :boolean, default: false, null: false)
    end
  end
end
