defmodule TudoChatWeb.Helpers.GroupMemberHelper do
  @moduledoc false
  use TudoChatWeb, :chat_helper
  alias Core.Accounts
  alias TudoChat.Groups

  def create_group_member(params) do
    new()
    |> run(:verify_bus_net_members, &verify_bus_net_members/2, &abort/3)
    |> run(:user_id, &make_user_id/2, &abort/3)
    |> run(:group_member, &create_group_member/2, &abort/3)
    |> transaction(TudoChat.Repo, params)
  end

  # -----------------------------------------------

  def verify_bus_net_members(_, %{member: member, group_id: group_id}) do
    case Groups.get_group(group_id) do
      nil ->
        {:error, ["chat group not found"]}

      %{service_request_id: nil, group_type_id: "my_net"} ->
        {:ok, ["valid"]}

      %{service_request_id: job_id, proposal_id: _, group_type_id: "bus_net"}
      when is_nil(job_id) ->
        {:ok, ["valid"]}

      %{service_request_id: job_id, group_type_id: "bus_net"} ->
        case apply(Core.BSP, :get_branch_by_job_id, [job_id]) do
          nil ->
            {:error, ["branch doesn't exist"]}

          %{id: branch_id} ->
            case member do
              %{employee_id: employee_id} ->
                case apply(Core.Employees, :get_employee, [employee_id]) do
                  nil ->
                    {:error, ["employee doesn't exist"]}

                  %{branch_id: emp_branch_id} ->
                    if emp_branch_id == branch_id,
                      do: {:ok, ["valid"]},
                      else: {:error, ["Irrelevant Employee"]}
                end

              _ ->
                {:error, ["employee_id is missing in params"]}
            end

            {:error, ["branch doesn't exist"]}
        end

        {:ok, ["valid"]}
    end
  end

  defp make_user_id(_, %{member: member}) do
    case member do
      %{user_id: user_id} ->
        {:ok, user_id}

      %{employee_id: employee_id} ->
        %{user_id: user_id} = apply(Core.Employees, :get_employee, [employee_id])
        {:ok, user_id}

      _ ->
        {:error, ["employee_id or user_id is missing in params"]}
    end
  end

  def create_group_member(
        _,
        %{
          member: %{role_id: role_id, user_id: user_id} = member,
          group_id: group_id,
          user_from_id: user_from_id
        } = input
      ) do
    input = Map.merge(input, Map.merge(member, %{is_active: false, user_id: user_id}))

    with %{} = user <- Accounts.get_user!(user_id),
         %TudoChat.Groups.Group{} = group <- Groups.get_group(group_id),
         %{} <- Groups.get_group_member_role(role_id),
         [] <- Groups.get_group_member_by(Map.delete(input, :role_id)),
         {:ok, member} <- Groups.create_group_member(input),
         {:ok, _} <- send_notification_and_email(Map.merge(member, %{user_from_id: user_from_id})) do
      TudoChatWeb.Endpoint.broadcast(
        "user:user_id:#{member.user_id}",
        "group_created",
        %{
          chat_group: TudoChatWeb.Channels.UserChannel.create_group_socket(group)
        }
      )

      {:ok, Map.merge(member, %{user: user})}
    else
      _ -> {:error, ["member can not created"]}
    end
  end

  def send_notification_and_email(%{user_id: user_id, group_id: group_id} = member) do
    group_name =
      case Groups.get_group(group_id) do
        %{name: name} -> name
        _ -> ""
      end

    case apply(Core.Accounts, :get_user!, [member.user_from_id]) do
      %{email: email, profile: %{"first_name" => first_name, "last_name" => last_name}} ->
        Exq.enqueue(
          Exq,
          "default",
          "TudoChatWeb.Workers.NotifyWorker",
          [
            [user_id],
            "New invitation received from #{first_name} #{last_name} in group #{group_name}",
            %{user_from: member.user_from_id}
          ]
        )

        Exq.enqueue(
          Exq,
          "default",
          "TudoChatWeb.Workers.NotificationEmailsWorker",
          [
            "friend_request",
            %{email: email, language: "en", name: first_name <> " " <> last_name}
          ]
        )
    end
  end
end
