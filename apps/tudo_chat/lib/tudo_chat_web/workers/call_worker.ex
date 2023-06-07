defmodule TudoChatWeb.Workers.CallWorker do
  @moduledoc false
  alias TudoChat.Calls.CallMeta
  alias TudoChat.Messages
  import TudoChatWeb.Utils.Errors

  def perform(call_id, participant_ids, initiator_id) do
    Enum.each(participant_ids, fn participant_id ->
      with %CallMeta{} = call_meta <-
             Messages.get_call_meta_by_call_id_and_user_id(call_id, participant_id) do
        if call_meta.status not in ["received", "declined", "ended"] do
          Messages.update_call_meta(call_meta, %{status: "missed"})
        end
      else
        _ -> %{error: "Something went wrong"}
      end
    end)

    case Messages.get_call_meta_by_call_id(%{call_id: call_id}) do
      [_ | _] = call_users ->
        missed_calls = Enum.reject(call_users, fn call_user -> call_user.status != "missed" end)

        if length(missed_calls) == length(call_users) do
          update_initiator_status(call_id, initiator_id)
        else
          :ok
        end
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        %{reason: "something wrong callworker"},
        __ENV__.line
      )
  end

  def update_initiator_status(call_id, initiator_id) do
    with %CallMeta{} = call_meta <-
           Messages.get_call_meta_by_call_id_and_user_id(call_id, initiator_id),
         {:ok, %CallMeta{} = data} <-
           Messages.update_call_meta(
             call_meta,
             %{status: "no answer"}
           ) do
      data
    else
      _ -> %{error: "something went wrong"}
    end
  end
end
