defmodule Stitch.Repo.Migrations.CreateSegmentEventsTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:segment_events) do
      add :payload, :map

      timestamps()
    end
  end
end
