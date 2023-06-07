defmodule Stitch.Repo.Migrations.AddMessagesTypeColumn do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :type, :string, default: "user_message"
    end
  end
end
