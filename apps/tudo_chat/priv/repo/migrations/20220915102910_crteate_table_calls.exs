defmodule TudoChat.Repo.Migrations.CreatetableCalls do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:calls) do
      add :group_id, references(:groups, on_delete: :nothing)
      add :initiator_id, :integer

      timestamps()
    end
  end
end
