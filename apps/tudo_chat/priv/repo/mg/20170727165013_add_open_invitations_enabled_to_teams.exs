defmodule Stitch.Repo.Migrations.AddOpenInvitationsEnabledToTeams do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :open_invitations_enabled, :boolean, default: false
    end
  end
end
