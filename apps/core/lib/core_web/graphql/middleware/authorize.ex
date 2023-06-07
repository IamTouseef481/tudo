defmodule CoreWeb.GraphQL.Middleware.Authorize do
  @moduledoc false
  @behaviour Absinthe.Middleware
  def call(resolution, role) do
    with %{current_user: %{status_id: user_status} = current_user} when user_status != "deleted" <-
           resolution.context,
         true <- current_role?(current_user, role) do
      #      Gettext.put_locale(CoreWeb.Gettext, current_user.acl_role_id)
      case user_status do
        "confirmed" ->
          resolution

        _status ->
          resolution |> Absinthe.Resolution.put_result({:error, "user status is not confirmed!"})
      end
    else
      _ -> resolution |> Absinthe.Resolution.put_result({:error, "unauthorized"})
    end
  end

  defp current_role?(%{}, :any), do: true
  defp current_role?(%{role: role}, role), do: true
  defp current_role?(_, _), do: false
end
