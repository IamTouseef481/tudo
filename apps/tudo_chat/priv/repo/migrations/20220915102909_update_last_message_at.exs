defmodule TudoChat.Repo.Migrations.UpdateLastMessageAt do
  @moduledoc false
  use Ecto.Migration
  alias TudoChat.Groups

  def change do
    Groups.groups_listing()
    |> Enum.each(fn
      %{id: id, created_by_id: user_id} = group ->
        case TudoChat.Messages.get_last_message_by_group_and_user(id, user_id) do
          nil ->
            Groups.update_group(group, %{last_message_at: group.inserted_at})

          %{created_at: message_time} ->
            Groups.update_group(group, %{last_message_at: message_time})
        end
    end)
  end
end
