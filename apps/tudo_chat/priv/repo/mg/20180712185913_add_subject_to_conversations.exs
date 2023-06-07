defmodule Stitch.Repo.Migrations.AddSubjectToConversations do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:conversations) do
      add(:subject, :string, null: false, default: "")
    end
  end
end
