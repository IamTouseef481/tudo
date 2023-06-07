defmodule Stitch.Repo.Migrations.AddInviteTokenToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :invite_token, :string
    end
  end
end
