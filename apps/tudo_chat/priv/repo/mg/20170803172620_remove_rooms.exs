defmodule Stitch.Repo.Migrations.RemoveRooms do
  @moduledoc false
  use Ecto.Migration

  def change do
    drop table(:rooms)
  end
end
