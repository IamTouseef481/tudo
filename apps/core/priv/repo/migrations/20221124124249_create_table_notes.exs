defmodule Core.Repo.Migrations.CreateTableNotes do
  use Ecto.Migration

  def change do
    create table(:job_notes) do
      add :note, :text
      add :note_type, :string
      add :user_id, :integer
      add :branch_id, :integer
      add :job_id, references(:jobs, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:job_notes, [:note_type, :job_id])
  end
end
