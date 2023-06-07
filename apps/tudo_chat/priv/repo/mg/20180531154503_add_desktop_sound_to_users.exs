defmodule Stitch.Repo.Migrations.AddDesktopSoundToUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:desktop_sound, :string, null: false, default: "pop")
    end
  end
end
