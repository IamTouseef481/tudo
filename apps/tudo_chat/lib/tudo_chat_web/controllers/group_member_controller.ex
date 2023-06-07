defmodule TudoChatWeb.Controllers.GroupMemberController do
  @moduledoc false
  use TudoChatWeb, :controller
  import TudoChatWeb.Utils.Errors
  alias TudoChat.Groups
  alias TudoChatWeb.Helpers.GroupMemberHelper

  @default_error ["unexpected error occurred!"]

  def create_group_members(%{members: members} = input) do
    members =
      Enum.reduce(members, [], fn %{role_id: _role_id} = member, acc ->
        with {:ok, _last, all} <-
               GroupMemberHelper.create_group_member(Map.merge(input, %{member: member})),
             %{group_member: member} <- all do
          [member | acc]
        else
          _ -> acc
        end
      end)

    {:ok, members}
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def update_group_member(%{role_id: _} = input) do
    case valid_for_updating_member_role(input) do
      {:ok, _} ->
        case Groups.get_group_member(input.id) do
          nil ->
            {:error, ["group member doesn't exist"]}

          %{} = member ->
            updating_group_member(member, input)

          exception ->
            logger(__MODULE__, exception, ["Error while getting group member"], __ENV__.line)
        end

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Error while verifying group member role for update"],
          __ENV__.line
        )
    end
  end

  def update_group_member(%{current_user_id: current_user_id, accept: true} = input) do
    case Groups.get_group_member(input.id) do
      nil ->
        {:error, ["group member doesn't exist"]}

      %{user_id: user_id} = member ->
        input = Map.merge(input, %{is_active: true})

        if current_user_id == user_id,
          do: updating_group_member(member, input),
          else: {:error, ["You are not allowed to perform this action!"]}

      _ ->
        {:error, ["some error while getting group member"]}
    end
  end

  def update_group_member(%{current_user_id: current_user_id, accept: false} = input) do
    case Groups.get_group_member(input.id) do
      nil ->
        {:error, ["group member doesn't exist"]}

      %{user_id: user_id} = member ->
        if current_user_id == user_id,
          do: deleting_group_member(member),
          else: {:error, ["You are not allowed to perform this action!"]}

      exception ->
        logger(__MODULE__, exception, ["Error while getting group member"], __ENV__.line)
    end
  end

  def update_group_member(input) do
    case Groups.get_group_member(input.id) do
      nil ->
        {:error, ["group member doesn't exist"]}

      %{user_id: _user_id} = member ->
        updating_group_member(member, input)

      exception ->
        logger(__MODULE__, exception, ["Error while getting group member"], __ENV__.line)
    end
  end

  defp updating_group_member(member, input) do
    case Groups.update_group_member(member, input) do
      {:ok, member} ->
        {:ok, member}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, ["Error while updating group member"], __ENV__.line)
    end
  end

  def get_current_user_group_member_role_for_update(previous_role, group_id, input) do
    case Groups.get_group_member_by(%{
           group_id: group_id,
           user_id: input.current_user_id,
           role_id: "super_admin"
         }) do
      [] ->
        case Groups.get_group_member_by(%{
               group_id: group_id,
               user_id: input.current_user_id,
               role_id: "admin"
             }) do
          [] ->
            {:error, ["You are not allowed to perform this action!"]}

          [%{role_id: current_user_role}] ->
            verify_group_member_roles_for_update(current_user_role, previous_role, input.role_id)
        end

      [%{role_id: current_user_role}] ->
        verify_group_member_roles_for_update(current_user_role, previous_role, input.role_id)
    end
  end

  defp verify_group_member_roles_for_update(
         current_user_role,
         previous_member_role,
         upcoming_member_role
       ) do
    case current_user_role do
      "super_admin" ->
        cond do
          previous_member_role == "member" and upcoming_member_role == "admin" ->
            {:ok, ["valid"]}

          previous_member_role == "admin" and upcoming_member_role == "member" ->
            {:ok, ["valid"]}

          true ->
            {:error,
             [
               "#{current_user_role} can't make #{previous_member_role} to #{upcoming_member_role}!"
             ]}
        end

      "admin" ->
        if previous_member_role in ["member"] and
             upcoming_member_role in ["admin"] do
          {:ok, ["valid"]}
        else
          {:error,
           ["#{current_user_role} can't make #{previous_member_role} to #{upcoming_member_role}!"]}
        end

      exception ->
        logger(
          __MODULE__,
          exception,
          ["#{current_user_role} can't make #{previous_member_role} to #{upcoming_member_role}!"],
          __ENV__.line
        )
    end
  end

  #  ----------------------------------------------------------------

  def delete_group_member(input) do
    case valid_for_deleting_member_role(input) do
      {:ok, member} ->
        deleting_group_member(member)

      {:error, error} ->
        {:error, error}

      exception ->
        logger(
          __MODULE__,
          exception,
          ["Error while verifying group member for delete"],
          __ENV__.line
        )
    end
  end

  #  def valid_for_creating_member(input) do
  #    case Groups.get_group_member_by(input) do
  #      [] -> {:ok, "valid"}
  #      _ -> {:error, "group member already exist"}
  #    end
  #  end

  def valid_for_updating_member_role(input) do
    case Groups.get_group_member(input.id) do
      %{role_id: previous_role, group_id: group_id} ->
        get_current_user_group_member_role_for_update(previous_role, group_id, input)

      exception ->
        logger(__MODULE__, exception, ["Group member does not exist"], __ENV__.line)
    end
  end

  def valid_for_deleting_member_role(input) do
    case Groups.get_group_member(input.id) do
      %{role_id: _role, group_id: group_id, user_id: _member_user_id} = member ->
        case Groups.get_group(group_id) do
          %{group_type_id: "my_net", marketing_group: true, name: "TUDO Marketing"} ->
            {:error, ["User is not allowed to delete TUDO Marketing group"]}

          %{group_type_id: "bus_net"} ->
            {:error, ["Not allowed to delete BusNet group member"]}

          _ ->
            case Groups.get_group_member_by(%{group_id: group_id, user_id: input.current_user_id}) do
              [] ->
                {:error, ["You are not allowed to perform this action!"]}

              [%{role_id: current_user_role} | _] ->
                verify_group_member_roles_for_delete(
                  current_user_role,
                  input.current_user_id,
                  member
                )
            end
        end

      exception ->
        logger(__MODULE__, exception, ["Group member does not exist"], __ENV__.line)
    end
  end

  #  defp get_group_member_role(role_id) do
  #    case Groups.get_group_member_role(role_id) do
  #      %{} -> {:ok, "valid"}
  #      _ -> {:error, ["invalid group member role"]}
  #    end
  #  end

  def deleting_group_member(member) do
    case Groups.update_group_member(member, %{deleted_at: DateTime.utc_now(), is_active: false}) do
      {:ok, %{role_id: "super_admin", group_id: group_id}} = member ->
        make_super_admin_on_leaving_super_admin(group_id)
        {:ok, member}

      {:ok, member} ->
        {:ok, member}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, ["error occurred while deleting group member!"]}
    end
  end

  defp make_super_admin_on_leaving_super_admin(group_id) do
    case Groups.get_group_member_for_making_super_admin(group_id, "admin") do
      nil ->
        case Groups.get_group_member_for_making_super_admin(group_id, "member") do
          nil -> {:ok, group_id}
          %{} = member -> Groups.update_group_member(member, %{role_id: "super_admin"})
        end

      %{} = member ->
        Groups.update_group_member(member, %{role_id: "super_admin"})
    end
  end

  def verify_group_member_roles_for_delete(
        current_user_role,
        current_user_id,
        %{role_id: role, user_id: member_user_id} = member
      ) do
    if member_user_id == current_user_id do
      {:ok, member}
    else
      cond do
        role in ["member", "admin"] and current_user_role == "super_admin" -> {:ok, member}
        role == "member" and current_user_role == "admin" -> {:ok, member}
        true -> {:error, ["you as #{current_user_role} can't remove #{role}"]}
      end
    end
  end
end
