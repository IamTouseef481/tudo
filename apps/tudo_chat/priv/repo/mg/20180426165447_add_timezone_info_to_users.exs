defmodule Stitch.Repo.Migrations.AddTimezoneInfoToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:timezone, :map, default: "{}")
    end
  end
end
