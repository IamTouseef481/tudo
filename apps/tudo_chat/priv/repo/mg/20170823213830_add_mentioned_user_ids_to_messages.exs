defmodule Stitch.Repo.Migrations.AddMentionedUserIdsToMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :mentioned_user_ids, {:array, :integer}, default: [], null: false
    end
  end
end
