defmodule Stitch.Repo.Migrations.AddReadStatusToMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :read_status, :map, default: "{}"
    end
  end
end
