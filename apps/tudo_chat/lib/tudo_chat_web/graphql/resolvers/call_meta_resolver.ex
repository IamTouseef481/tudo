defmodule TudoChatWeb.GraphQL.Resolvers.CallMetaResolver do
  @moduledoc false
  alias TudoChat.Messages

  def get_call_meta(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    {:ok,
     %{
       call_participants:
         Messages.get_call_meta(input.call_id)
         |> merge_user(),
       call_id: input.call_id
     }}
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
