defmodule TudoChat.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias TudoChat.Repo

  alias TudoChat.Groups.{Group, GroupMember, GroupMemberRole, GroupStatus, GroupType}
  alias TudoChat.Messages.{ComGroupMessage, MessageMeta}
  @prefix "tudo_"

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group, prefix: Triplex.to_prefix(@prefix))
  end

  def groups_listing do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id, prefix: Triplex.to_prefix(@prefix))
  def get_group(id), do: Repo.get(Group, id)

  def get_group_with_members(id) do
    from(g in Group,
      where: g.id == ^id,
      preload: [group_members: ^get_group_memebers()]
      # preload: get_group_memebers
    )
    |> Repo.one()
  end

  def get_group_memebers() do
    GroupMember
    |> where([gm], gm.is_active == true and is_nil(gm.deleted_at))
  end

  def get_group_by_user(%{group_id: group_id, user_id: user_id}) do
    from(g in Group,
      join: gm in GroupMember,
      on: g.id == gm.group_id,
      where: g.id == ^group_id and gm.user_id == ^user_id
    )
    |> Repo.all()
  end

  def get_groups_by_bid(%{bidding_job_id: id}) do
    from(g in Group,
      where: g.bid_id == ^id
    )
    |> Repo.all()
  end

  def get_group_by(%{proposal_id: id}) do
    from(g in Group,
      where: g.proposal_id == ^id
    )
    |> Repo.all()
  end

  def get_group_by(%{service_request_id: id}) do
    from(g in Group,
      where: g.service_request_id == ^id
    )
    |> Repo.all()
  end

  # def get_super_admin_user_id(group_id) do
  #   from(gm in GroupMember,
  #     where: gm.group_id == ^group_id,
  #     where: gm.role_id == ^"super_admin",
  #     select: gm.user_id
  #   )
  #   |> Repo.one()
  # end

  #  def get_groups_by(%{user_id: user_id, group_status_id: status, group_type_id: type}) do
  #    from(g in Group,
  #      join: gm in GroupMember, on: g.id == gm.group_id,
  #      where: gm.user_id == ^user_id and g.group_status_id ==^status and
  #            g.group_type_id == ^type and g.group_status_id == "active",
  #      distinct: [g.id])
  #    |> Repo.all()
  #  end
  #
  #  def get_groups_by(%{user_id: user_id, group_status_id: status}) do
  #    from(g in Group,
  #      join: gm in GroupMember, on: g.id == gm.group_id,
  #      where: gm.user_id == ^user_id and g.group_status_id ==^status and g.group_status_id == "active",
  #      distinct: [g.id])
  #    |> Repo.all()
  #  end
  #
  #  def get_groups_by(%{user_id: user_id, group_type_id: type}) do
  #    from(g in Group,
  #      join: gm in GroupMember, on: g.id == gm.group_id,
  #      where: gm.user_id == ^user_id and g.group_type_id == ^type and g.group_status_id == "active",
  #      distinct: [g.id])
  #    |> Repo.all()
  #  end
  #
  #  def get_groups_by(%{user_id: user_id}) do
  #    from(g in Group,
  #      join: gm in GroupMember, on: g.id == gm.group_id,
  #      where: gm.user_id == ^user_id and g.group_status_id == "active",
  #      distinct: [g.id])
  #    |> Repo.all()
  #  end

  def get_groups_for_listing(%{user_id: user_id, branch_id: branch_id}) do
    _last_message_query =
      from(m in ComGroupMessage,
        order_by: [desc: m.inserted_at]
      )

    from(g in Group,
      join: gm in GroupMember,
      on: g.id == gm.group_id and gm.user_id == ^user_id,
      where: g.group_status_id == "active" and g.branch_id == ^branch_id,
      order_by: [desc_nulls_last: g.last_message_at],
      # distinct: [g.id],
      #      preload: [last_message: ^last_message_query],
      preload: [:group_members]
    )
    |> Repo.all()
  end

  def get_groups_for_listing(%{user_id: user_id}) do
    _last_message_query =
      from(m in ComGroupMessage,
        order_by: [desc: m.inserted_at],
        select: m,
        limit: 1
      )

    #      ComGroupMessage
    #      |> last()
    #      |> select([m], m.message)

    _count_query =
      from(m in ComGroupMessage,
        join: mm in MessageMeta,
        on: m.id == mm.message_id,
        where: mm.user_id == ^user_id and mm.deleted == false and mm.read == false,
        #        select: m.id
        select: count(m.id)
      )

    from(g in Group,
      join: gm in GroupMember,
      on: g.id == gm.group_id,
      left_join: e in Core.Schemas.Employee,
      on: e.branch_id == g.branch_id,
      where: gm.user_id == ^user_id and g.group_status_id == "active" and e.user_id != ^user_id,
      distinct: [g.id],
      preload: [:group_members]
    )

    from(g in Group,
      join: gm in GroupMember,
      on: g.id == gm.group_id and gm.user_id == ^user_id,
      where: g.group_status_id == "active",
      # distinct: [g.id],
      #      preload: [last_message: ^last_message_query],
      order_by: [desc_nulls_last: g.name == "TUDO Marketing"],
      order_by: [desc_nulls_last: g.last_message_at],
      preload: [:group_members]
      #      preload: [last_message: ^message_query, unread_message_count: ^count_query]
    )
    |> Repo.all()

    #    |> Repo.all() |> Enum.map(&Repo.preload(&1, [last_message: message_query]))
  end

  def get_group_by_com_group_message(message_id) do
    from(g in Group,
      join: m in TudoChat.Messages.ComGroupMessage,
      on: g.id == m.group_id,
      where: m.id == ^message_id
    )
    |> Repo.one()
  end

  def limited_preloads do
    messages_query =
      from(m in ComGroupMessage,
        limit: 2
      )

    from(g in Group,
      left_join: gm in GroupMember,
      on: g.id == gm.group_id,
      where: g.group_status_id == "active",
      #      distinct: [g.id],
      preload: [messages: ^messages_query]
    )
    |> Repo.all()
  end

  def get_for_proposals_rejection(proposal_ids, user_id) do
    from(g in Group,
      join: m in ComGroupMessage,
      on: m.group_id == g.id,
      join: mm in MessageMeta,
      on: mm.message_id == m.id,
      where:
        g.proposal_id in ^proposal_ids and
          (not mm.read and mm.deleted == false and mm.user_id == ^user_id),
      distinct: g.id,
      select: g.id
    )
    |> Repo.all()
    |> Enum.count()
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    {:ok, group} =
      %Group{}
      |> Group.changeset(attrs)
      |> Repo.insert()

    case update_group(group, %{
           link:
             apply(CoreWeb.Utils.CommonFunctions, :generate_url, ["chat_group/join", group.id])
         }) do
      {:ok, data} -> {:ok, data}
      _ -> {:error, "Error in creating group"}
    end

    #    |> Repo.insert(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()

    #    |> Repo.update(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    #    Repo.delete(group, prefix: Triplex.to_prefix(@prefix))
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end

  @doc """
  Returns the list of group_types.

  ## Examples

      iex> list_group_types()
      [%GroupType{}, ...]

  """
  def list_group_types do
    Repo.all(GroupType)
    #    Repo.all(GroupType, prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Gets a single group_type.

  Raises `Ecto.NoResultsError` if the Group type does not exist.

  ## Examples

      iex> get_group_type!(123)
      %GroupType{}

      iex> get_group_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_type!(id), do: Repo.get!(GroupType, id, prefix: Triplex.to_prefix(@prefix))
  def get_group_type(id), do: Repo.get(GroupType, id)

  @doc """
  Creates a group_type.

  ## Examples

      iex> create_group_type(%{field: value})
      {:ok, %GroupType{}}

      iex> create_group_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_type(attrs \\ %{}) do
    %GroupType{}
    |> GroupType.changeset(attrs)
    #    |> Repo.insert(prefix: Triplex.to_prefix(@prefix))
    |> Repo.insert()
  end

  @doc """
  Updates a group_type.

  ## Examples

      iex> update_group_type(group_type, %{field: new_value})
      {:ok, %GroupType{}}

      iex> update_group_type(group_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_type(%GroupType{} = group_type, attrs) do
    group_type
    |> GroupType.changeset(attrs)
    |> Repo.update()

    #    |> Repo.update(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Deletes a GroupType.

  ## Examples

      iex> delete_group_type(group_type)
      {:ok, %GroupType{}}

      iex> delete_group_type(group_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_type(%GroupType{} = group_type) do
    Repo.delete(group_type)
    #    Repo.delete(group_type, prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_type changes.

  ## Examples

      iex> change_group_type(group_type)
      %Ecto.Changeset{source: %GroupType{}}

  """
  def change_group_type(%GroupType{} = group_type) do
    GroupType.changeset(group_type, %{})
  end

  @doc """
  Returns the list of group_members.

  ## Examples

      iex> list_group_members()
      [%GroupMember{}, ...]

  """
  def list_group_members do
    Repo.all(GroupMember, prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Gets a single group_member.

  Raises `Ecto.NoResultsError` if the Group member does not exist.

  ## Examples

      iex> get_group_member!(123)
      %GroupMember{}

      iex> get_group_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_member!(id), do: Repo.get!(GroupMember, id, prefix: Triplex.to_prefix(@prefix))
  def get_group_member(id), do: Repo.get(GroupMember, id)

  def get_group_member_by(%{group_id: group_id, user_id: user_id, role_id: role}) do
    from(gm in GroupMember,
      where: gm.group_id == ^group_id and gm.user_id == ^user_id and gm.role_id == ^role
    )
    |> Repo.all()
  end

  def get_group_member_by(%{group_id: group_id, user_id: user_id, role_ids: roles}) do
    from(gm in GroupMember,
      where: gm.group_id == ^group_id and gm.user_id == ^user_id and gm.role_id in ^roles
    )
    |> Repo.all()
  end

  def get_group_member_by(%{group_id: group_id, user_id: user_id}) do
    from(gm in GroupMember, where: gm.group_id == ^group_id and gm.user_id == ^user_id)
    |> Repo.all()
  end

  def get_group_member_by(user_id, group_id) do
    from(gm in GroupMember,
      join: g in Group,
      on: g.id == gm.group_id,
      where: g.id == ^group_id,
      where: g.name != ^"TUDO Marketing",
      where: g.group_type_id != ^"bus_net",
      where: gm.user_id == ^user_id
    )
    |> Repo.one()
  end

  def get_group_member_by_user_id(user_id) do
    from(gm in GroupMember,
      join: g in Group,
      on: g.id == gm.group_id,
      where: gm.user_id == ^user_id and g.name != ^"TUDO Marketing",
      where: is_nil(gm.deleted_at) and gm.is_active == true
    )
    |> Repo.all()
  end

  def get_group_member_role_by(%{group_id: group_id, user_id: user_id}) do
    from(gm in GroupMember,
      where: gm.group_id == ^group_id and gm.user_id == ^user_id,
      select: gm.role_id,
      limit: 1,
      order_by: [desc: gm.inserted_at]
    )
    |> Repo.one()
  end

  def get_active_group_member_by(%{group_id: group_id, user_id: user_id}) do
    from(gm in GroupMember,
      where: gm.group_id == ^group_id and gm.user_id == ^user_id and gm.is_active
    )
    |> Repo.all()
  end

  def get_group_members_by_group(group_id) do
    from(gm in GroupMember, where: gm.group_id == ^group_id)
    |> Repo.all()
  end

  def get_active_group_member_user_ids_by_group(group_id) do
    from(gm in GroupMember,
      where: gm.group_id == ^group_id and gm.is_active and is_nil(gm.deleted_at),
      select: gm.user_id
    )
    |> Repo.all()
  end

  def get_group_member_user_ids_by_group(group_id) do
    from(gm in GroupMember, where: gm.group_id == ^group_id, select: gm.user_id)
    |> Repo.all()
  end

  def get_group_member_for_making_super_admin(group_id, role) do
    from(gm in GroupMember,
      join: g in Group,
      on: g.id == gm.group_id,
      where: gm.group_id == ^group_id and gm.is_active and gm.role_id == ^role,
      limit: 1,
      order_by: [gm.inserted_at]
    )
    |> Repo.one()
  end

  #  def get_group_members_by_message(msg_id) do
  #    from(gm in GroupMember,
  #      join: g in Group, on: g.id == gm.group_id,
  #      join: m in ComGroupMessage, on: g.id == m.group_id,
  #      where: m.id == ^msg_id)
  #    |> Repo.all()
  #  end

  @doc """
  Creates a group_member.

  ## Examples

      iex> create_group_member(%{field: value})
      {:ok, %GroupMember{}}

      iex> create_group_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_member(attrs \\ %{}) do
    %GroupMember{}
    |> GroupMember.changeset(attrs)
    #    |> Repo.insert(prefix: Triplex.to_prefix(@prefix))
    |> Repo.insert()
  end

  @doc """
  Updates a group_member.

  ## Examples

      iex> update_group_member(group_member, %{field: new_value})
      {:ok, %GroupMember{}}

      iex> update_group_member(group_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_member(%GroupMember{} = group_member, attrs) do
    group_member
    |> GroupMember.changeset(attrs)
    |> Repo.update()

    #    |> Repo.update(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Deletes a GroupMember.

  ## Examples

      iex> delete_group_member(group_member)
      {:ok, %GroupMember{}}

      iex> delete_group_member(group_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_member(%GroupMember{} = group_member) do
    #    Repo.delete(group_member, prefix: Triplex.to_prefix(@prefix))
    Repo.delete(group_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_member changes.

  ## Examples

      iex> change_group_member(group_member)
      %Ecto.Changeset{source: %GroupMember{}}

  """
  def change_group_member(%GroupMember{} = group_member) do
    GroupMember.changeset(group_member, %{})
  end

  @doc """
  Returns the list of group_statuses.

  ## Examples

      iex> list_group_statuses()
      [%GroupStatus{}, ...]

  """
  def list_group_statuses do
    Repo.all(GroupStatus)
  end

  @doc """
  Gets a single group_status.

  Raises `Ecto.NoResultsError` if the Group status does not exist.

  ## Examples

      iex> get_group_status!(123)
      %GroupStatus{}

      iex> get_group_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_status!(id), do: Repo.get!(GroupStatus, id)
  def get_group_status(id), do: Repo.get(GroupStatus, id)

  @doc """
  Creates a group_status.

  ## Examples

      iex> create_group_status(%{field: value})
      {:ok, %GroupStatus{}}

      iex> create_group_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_status(attrs \\ %{}) do
    %GroupStatus{}
    |> GroupStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_status.

  ## Examples

      iex> update_group_status(group_status, %{field: new_value})
      {:ok, %GroupStatus{}}

      iex> update_group_status(group_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_status(%GroupStatus{} = group_status, attrs) do
    group_status
    |> GroupStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_status.

  ## Examples

      iex> delete_group_status(group_status)
      {:ok, %GroupStatus{}}

      iex> delete_group_status(group_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_status(%GroupStatus{} = group_status) do
    Repo.delete(group_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_status changes.

  ## Examples

      iex> change_group_status(group_status)
      %Ecto.Changeset{source: %GroupStatus{}}

  """
  def change_group_status(%GroupStatus{} = group_status) do
    GroupStatus.changeset(group_status, %{})
  end

  @doc """
  Returns the list of group_member_roles.

  ## Examples

      iex> list_group_member_roles()
      [%GroupMemberRole{}, ...]

  """
  def list_group_member_roles do
    Repo.all(GroupMemberRole)
  end

  @doc """
  Gets a single group_member_role.

  Raises `Ecto.NoResultsError` if the Group member role does not exist.

  ## Examples

      iex> get_group_member_role!(123)
      %GroupMemberRole{}

      iex> get_group_member_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group_member_role!(id), do: Repo.get!(GroupMemberRole, id)
  def get_group_member_role(id), do: Repo.get(GroupMemberRole, id)

  @doc """
  Creates a group_member_role.

  ## Examples

      iex> create_group_member_role(%{field: value})
      {:ok, %GroupMemberRole{}}

      iex> create_group_member_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group_member_role(attrs \\ %{}) do
    %GroupMemberRole{}
    |> GroupMemberRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group_member_role.

  ## Examples

      iex> update_group_member_role(group_member_role, %{field: new_value})
      {:ok, %GroupMemberRole{}}

      iex> update_group_member_role(group_member_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group_member_role(%GroupMemberRole{} = group_member_role, attrs) do
    group_member_role
    |> GroupMemberRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group_member_role.

  ## Examples

      iex> delete_group_member_role(group_member_role)
      {:ok, %GroupMemberRole{}}

      iex> delete_group_member_role(group_member_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group_member_role(%GroupMemberRole{} = group_member_role) do
    Repo.delete(group_member_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group_member_role changes.

  ## Examples

      iex> change_group_member_role(group_member_role)
      %Ecto.Changeset{source: %GroupMemberRole{}}

  """
  def change_group_member_role(%GroupMemberRole{} = group_member_role) do
    GroupMemberRole.changeset(group_member_role, %{})
  end

  def get_group_by_user_id(user_id) do
    query =
      from(g in Group,
        where: g.created_by_id in ^user_id and g.name == "TUDO Marketing",
        select: g.id
      )

    Repo.all(query)
  end

  def get_group_type_by_group_id(group_id) do
    Group
    |> where([g], g.id == ^group_id)
    |> select([g], g.group_type_id)
    |> Repo.one()
  end
end
