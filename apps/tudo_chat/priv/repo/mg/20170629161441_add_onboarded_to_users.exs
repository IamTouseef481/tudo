defmodule Stitch.Repo.Migrations.AddOnboardedToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :onboarded, :boolean, default: false
    end
  end
end
