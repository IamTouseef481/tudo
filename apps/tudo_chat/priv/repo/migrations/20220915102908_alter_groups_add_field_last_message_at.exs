defmodule TudoChat.Repo.Migrations.AlterGroupsAddFieldLastMessageAt do
  @moduledoc false
  use Ecto.Migration
  alias TudoChat.Groups

  def change do
    alter(table(:groups)) do
      add_if_not_exists :last_message_at, :utc_datetime
    end
  end
end
