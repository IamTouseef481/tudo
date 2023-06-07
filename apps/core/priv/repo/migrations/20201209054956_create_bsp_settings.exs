defmodule Core.Repo.Migrations.CreateBspSettings do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:bsp_settings) do
      add :title, :string
      add :slug, :string
      add :type, :string
      add :fields, {:array, :map}
      add :branch_id, references(:branches, on_delete: :nothing)

      timestamps()
    end

    create index(:bsp_settings, [:branch_id])
  end
end
