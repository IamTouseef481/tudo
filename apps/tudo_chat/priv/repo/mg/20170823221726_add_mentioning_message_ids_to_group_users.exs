defmodule Stitch.Repo.Migrations.AddMentioningMessageIdsToGroupUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:group_users) do
      add :mentioning_message_ids, :map, default: "{}", null: false
    end
  end
end
