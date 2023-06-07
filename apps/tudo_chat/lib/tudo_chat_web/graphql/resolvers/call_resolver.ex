defmodule TudoChatWeb.GraphQL.Resolvers.CallResolver do
  @moduledoc false
  alias TudoChat.Messages

  def calls(_, _, %{context: %{current_user: current_user}}) do
    {:ok,
     Messages.get_calls(current_user.id)
     |> get_call_meta()}
  end

  def get_call_meta(calls) do
    Enum.map(calls, fn call ->
      case Messages.get_call_meta(call.id) do
        [] ->
          %{call_id: nil, call_detail: []}

        call_metas ->
          %{call_id: call.id, call_detail: merge_user(call_metas)}
      end
    end)
  end

  def merge_user(call_metas) do
    Enum.map(call_metas, fn call_meta ->
      Map.merge(
        %{
          call_start_time: call_meta.call_start_time,
          call_end_time: call_meta.call_end_time,
          status: call_meta.status,
          admin: call_meta.admin,
          call_duration: call_meta.call_duration,
          call_id: call_meta.call_id,
          id: call_meta.id
        },
        %{
          user:
            apply(Core.Accounts, :get_user_short_object_for_call_meta, [
              call_meta.participant_id
            ])
        }
      )
    end)
  end
end
