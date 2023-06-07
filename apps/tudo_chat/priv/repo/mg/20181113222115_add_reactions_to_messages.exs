defmodule Stitch.Repo.Migrations.AddReactionsToMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:reactions, :map, default: %{}, null: false)
    end
  end
end
