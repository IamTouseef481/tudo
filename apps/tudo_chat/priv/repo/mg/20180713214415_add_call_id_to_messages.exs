defmodule Stitch.Repo.Migrations.AddCallIdToMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add(:call_id, references(:calls, on_delete: :delete_all))
    end
  end
end
