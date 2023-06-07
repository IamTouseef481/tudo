defmodule TudoChatWeb.GraphQL.Types.GroupMemberType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type
  import Ecto.Query
  alias TudoChat.{Accounts.User, Groups.Group}

  object :group_member_type do
    field :id, :id
    field :is_active, :boolean
    field :group_id, :integer
    field :group, :group_type, resolve: assoc(:group)
    field :role, :role_type, resolve: assoc(:role)
    field :user_id, :integer
    field :user, :user_type
    #      field :user, :user_type do
    #        resolve fn group_member, _, _ ->
    #          batch({__MODULE__, :users_by_id}, group_member.user_id, fn batch_results ->
    #            {:ok, Map.get(batch_results, group_member.user_id)}
    #          end)
    #        end
    #      end
    #      field :group, :group_type do
    #        resolve fn group, _, _ ->
    #          batch({__MODULE__, :group_types_by_id}, group.group_id, fn batch_results ->
    #            {:ok, Map.get(batch_results, group.group_id)}
    #          end)
    #        end
    #      end
  end

  object :role_type do
    field :id, :string
    field :description, :string
  end

  input_object :group_member_input_type do
    field :members, non_null(list_of(:member))
    field :group_id, non_null(:integer)
    field :is_active, :boolean
  end

  input_object :member do
    field :employee_id, :integer
    field :user_id, :integer
    field :role_id, non_null(:string)
  end

  input_object :group_member_update_type do
    field :id, non_null(:integer)
    field :role_id, :string
    field :accept, :boolean
  end

  input_object :group_member_delete_type do
    field :id, non_null(:integer)
  end

  def users_by_id(_, ids) do
    User
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end

  def group_types_by_id(_, ids) do
    Group
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end
end
