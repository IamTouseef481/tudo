defmodule Stitch.Repo.Migrations.AddCreatorUserIdToGroups do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :creator_user_id, references(:users, on_delete: :nothing)
    end
  end
end
