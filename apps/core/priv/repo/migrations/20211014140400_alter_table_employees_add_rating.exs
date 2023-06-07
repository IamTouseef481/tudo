defmodule Core.Repo.Migrations.AlterTableEmployeesAddRating do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter(table(:employees)) do
      add :rating, :float, default: 0.0
    end
  end
end
