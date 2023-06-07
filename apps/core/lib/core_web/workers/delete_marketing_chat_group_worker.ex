defmodule CoreWeb.Workers.DeleteMarketingChatGroupWorker do
  @moduledoc false
  use CoreWeb, :core_helper
  alias TudoChat.Messages

  def perform(id) do
    delete_group_message(id)
  end

  def delete_group_message(message_id) do
    new()
    |> run(:message, &deletes_group_message/2, &abort/3)
    |> transaction(TudoChat.Repo, message_id)
  rescue
    exception ->
      logger(__MODULE__, exception, ["could not de delete message"], __ENV__.line)
  end

  defp deletes_group_message(_, message_id) do
    case apply(Messages, :get_com_group_message, [message_id]) do
      nil ->
        {:ok, ["Nothing to delete"]}

      %{} = message ->
        apply(Messages, :delete_all_message_meta_by_message, [message_id])
        apply(Messages, :delete_com_group_message, [message])
    end
  end
end
