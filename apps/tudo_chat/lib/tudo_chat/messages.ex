defmodule TudoChat.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  import TudoChatWeb.Utils.Errors
  alias TudoChat.Groups.Group
  alias TudoChat.Messages.ComGroupMessage
  alias TudoChat.Messages.{JobStatus, MessageMeta}
  alias TudoChat.Repo
  alias TudoChatWeb.Utils.Paginator
  alias TudoChat.Messages.{MessageMeta, JobStatus}
  alias TudoChat.Groups.Group
  alias TudoChat.Calls.Call
  alias TudoChat.Calls.CallMeta

  @prefix "tudo_"

  @doc """
  Returns the list of com_group_messages.

  ## Examples

      iex> list_com_group_messages()
      [%ComGroupMessage{}, ...]

  """
  def list_com_group_messages do
    Repo.all(ComGroupMessage, prefix: Triplex.to_prefix(@prefix))
  end

  def get_job_status(id), do: Repo.get(JobStatus, id)

  @doc """
  Gets a single com_group_message.

  Raises `Ecto.NoResultsError` if the Com group message does not exist.

  ## Examples

      iex> get_com_group_message!(123)
      %ComGroupMessage{}

      iex> get_com_group_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_com_group_message!(id),
    do: Repo.get!(ComGroupMessage, id, prefix: Triplex.to_prefix(@prefix))

  def get_com_group_message(id), do: Repo.get(ComGroupMessage, id)

  #  general to be embedded in custom query
  def get_my_net_messages_query(
        %{group_id: group_id, user_id: user_id} = _input,
        min_duration_limit
      ) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id and mm.user_id == ^user_id and mm.deleted == false,
      where: m.group_id == ^group_id and m.inserted_at >= ^min_duration_limit,
      preload: [message_meta: mm]
    )
  end

  #  general to be embedded in custom query
  def get_bus_net_messages_query(%{group_id: group_id, user_id: user_id} = _input) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id and mm.user_id == ^user_id and mm.deleted == false,
      where: m.group_id == ^group_id,
      preload: [message_meta: mm]
    )
  end

  #  get favourite messages
  def get_favourite_messages_query(query, %{user_id: user_id, favourite: fav} = _input) do
    from([m, mm] in query, where: mm.user_id == ^user_id and mm.favourite == ^fav)
  end

  #  get read messages
  def get_read_messages_query(query, %{user_id: user_id, read: read} = _input) do
    from([m, mm] in query, where: mm.user_id == ^user_id and mm.read == ^read)
  end

  #  get liked messages
  def get_liked_messages_query(query, %{user_id: user_id, liked: liked} = _input) do
    from([m, mm] in query, where: mm.user_id == ^user_id and mm.read == ^liked)
  end

  #  get searched messages
  def get_searched_messages_query(query, %{search_pattern: str} = _input) do
    from([m, mm] in query, where: ilike(m.message, ^"%#{str}%"))
  end

  #  exclude messages of blocked  members
  def exclude_messages_of_blocked_members_query(query, user_ids) do
    from([m, mm] in query, where: m.user_from_id not in ^user_ids)
  end

  #  when no extra parameter sent
  def get_messages_by(query, _input), do: query

  #  sort and get messages
  def sort_and_get_messages(query, input) do
    query =
      case input do
        %{ascending_order: true} -> from([m, mm] in query, order_by: [asc: m.id])
        _ -> from([m, mm] in query, order_by: [desc: m.id])
      end

    query
    |> Scrivener.Paginater.paginate(Paginator.make_pagination_params())
  end

  def get_unread_messages_count_by_group_and_user(
        %{group_id: group_id, user_id: user_id} = _input
      ) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id,
      where:
        m.group_id == ^group_id and
          (mm.user_id == ^user_id and mm.deleted == false and mm.read == false),
      select: count(m.id)
    )
    |> Repo.one()
  end

  def get_last_message_by_group_and_user(group_id, user_id) do
    from(m in ComGroupMessage,
      join: g in Group,
      on: g.id == m.group_id,
      join: mm in MessageMeta,
      on: m.id == mm.message_id and mm.user_id == ^user_id and mm.deleted == false,
      order_by: [desc: m.inserted_at],
      where: g.id == ^group_id,
      limit: 1
    )
    |> Repo.one()
  end

  def get_unread_messages_meta_by_group_and_user(%{group_id: group_id, user_id: user_id}) do
    from(mm in MessageMeta,
      join: m in ComGroupMessage,
      on: m.id == mm.message_id,
      where:
        m.group_id == ^group_id and
          (mm.user_id == ^user_id and mm.deleted == false and mm.read == false)
    )
    |> Repo.all()
  end

  #  def get_unread_messages_count_by_user(%{user_id: user_id} = _input) do
  #    from(m in ComGroupMessage,
  #      join: mm in MessageMeta, on: m.id == mm.message_id,
  #      where: (mm.user_id == ^user_id and mm.deleted == false and mm.read == false),
  #      select: count(m.id)
  #    )
  #    |> Repo.one()
  #  end

  def get_unread_messages_count_by_user_and_group_type(user_id, group_type) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id,
      join: g in TudoChat.Groups.Group,
      on: m.group_id == g.id,
      where:
        g.group_type_id == ^group_type and
          (mm.user_id == ^user_id and mm.deleted == false and mm.read == false),
      select: %{group_id: m.group_id}
    )
    |> Repo.all()
    |> Enum.group_by(& &1.group_id)
    |> Enum.count()
  end

  def check_if_any_unread_bus_net_message_by_user_and_group_type(user_id, group_type, roles) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id,
      join: g in TudoChat.Groups.Group,
      on: m.group_id == g.id,
      join: gm in TudoChat.Groups.GroupMember,
      on: gm.group_id == g.id,
      where:
        g.group_type_id == ^group_type and gm.role_id in ^roles and
          gm.user_id == ^user_id and
          (mm.user_id == ^user_id and mm.deleted == false and mm.read == false),
      limit: 1
    )
    |> Repo.one()
  end

  def get_group_with_message_id(id) do
    from(m in ComGroupMessage,
      where: m.id == ^id,
      select: %{group_id: m.group_id}
    )
    |> Repo.one()
  end

  #  for downloading messages
  def get_group_messages_by_group(%{group_id: group_id, user_id: user_id} = _input) do
    from(m in ComGroupMessage,
      join: mm in MessageMeta,
      on: m.id == mm.message_id,
      where: m.group_id == ^group_id and (mm.user_id == ^user_id and mm.deleted == false)
    )
    |> Repo.all()
  end

  def get_last_message_by_group(group_id, user_id) do
    ComGroupMessage
    |> join(:full, [m], mm in MessageMeta,
      on: m.id == mm.message_id and mm.user_id == ^user_id and mm.deleted == false
    )
    |> where(
      [m, mm],
      m.group_id == ^group_id
    )
    |> last()
    |> select([m, mm], m.message)
    |> Repo.one()
  end

  @doc """
  Creates a com_group_message.

  ## Examples

      iex> create_com_group_message(%{field: value})
      {:ok, %ComGroupMessage{}}

      iex> create_com_group_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_com_group_message(attrs \\ %{}) do
    %ComGroupMessage{}
    |> ComGroupMessage.changeset(attrs)
    |> Repo.insert()

    #    |> Repo.insert(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Updates a com_group_message.

  ## Examples

      iex> update_com_group_message(com_group_message, %{field: new_value})
      {:ok, %ComGroupMessage{}}

      iex> update_com_group_message(com_group_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_com_group_message(%ComGroupMessage{} = com_group_message, attrs) do
    com_group_message
    |> ComGroupMessage.changeset(attrs)
    |> Repo.update(prefix: Triplex.to_prefix(@prefix))
  end

  @doc """
  Deletes a ComGroupMessage.

  ## Examples

      iex> delete_com_group_message(com_group_message)
      {:ok, %ComGroupMessage{}}

      iex> delete_com_group_message(com_group_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_com_group_message(%ComGroupMessage{} = com_group_message) do
    Repo.delete(com_group_message)
    #    Repo.delete(com_group_message, prefix: Triplex.to_prefix(@prefix))
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking com_group_message changes.

  ## Examples

      iex> change_com_group_message(com_group_message)
      %Ecto.Changeset{source: %ComGroupMessage{}}

  """
  def change_com_group_message(%ComGroupMessage{} = com_group_message) do
    ComGroupMessage.changeset(com_group_message, %{})
  end

  @doc """
  Returns the list of messages_meta.

  ## Examples

      iex> list_messages_meta()
      [%MessageMeta{}, ...]

  """
  def list_messages_meta do
    Repo.all(MessageMeta)
  end

  @doc """
  Gets a single message_meta.

  Raises `Ecto.NoResultsError` if the Message meta does not exist.

  ## Examples

      iex> get_message_meta!(123)
      %MessageMeta{}

      iex> get_message_meta!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message_meta!(id), do: Repo.get!(MessageMeta, id)
  def get_message_meta(id), do: Repo.get(MessageMeta, id)

  def get_message_meta_by_user_and_message(user_id, message_id) do
    from(mm in MessageMeta, where: mm.user_id == ^user_id and mm.message_id == ^message_id)
    |> Repo.all()
  end

  @doc """
  Creates a message_meta.

  ## Examples

      iex> create_message_meta(%{field: value})
      {:ok, %MessageMeta{}}

      iex> create_message_meta(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message_meta(attrs \\ %{}) do
    %MessageMeta{}
    |> MessageMeta.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message_meta.

  ## Examples

      iex> update_message_meta(message_meta, %{field: new_value})
      {:ok, %MessageMeta{}}

      iex> update_message_meta(message_meta, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message_meta(%MessageMeta{} = message_meta, attrs) do
    message_meta
    |> MessageMeta.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message_meta.

  ## Examples

      iex> delete_message_meta(message_meta)
      {:ok, %MessageMeta{}}

      iex> delete_message_meta(message_meta)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message_meta(%MessageMeta{} = message_meta) do
    Repo.delete(message_meta)
  end

  def delete_all_message_meta_by_message(id) do
    from(mm in MessageMeta, where: mm.message_id == ^id)
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message_meta changes.

  ## Examples

      iex> change_message_meta(message_meta)
      %Ecto.Changeset{source: %MessageMeta{}}

  """
  def change_message_meta(%MessageMeta{} = message_meta) do
    MessageMeta.changeset(message_meta, %{})
  end

  def update_call_meta(%CallMeta{} = callmeta, attrs) do
    callmeta
    |> CallMeta.changeset(attrs)
    |> Repo.update()
  end

  def get_call_meta_by_call_id_and_user_id(call_id, user_id) do
    CallMeta
    |> where([cm], cm.call_id == ^call_id and cm.participant_id == ^user_id)
    |> limit(1)
    |> Repo.one()
  end

  def create_call(attrs) do
    %Call{}
    |> Call.changeset(attrs)
    |> Repo.insert()
  end

  def create_call_meta(attrs) do
    %CallMeta{}
    |> CallMeta.changeset(attrs)
    |> Repo.insert()
  end

  def get_initiator_meta_by_call_id_and_status(call_id) do
    CallMeta
    |> where([cm], cm.call_id == ^call_id)
    |> where([cm], cm.status in ["call_start", "received", "ended"])
    |> where([cm], cm.admin == true)
    |> limit(1)
    |> Repo.one()
  end

  def get_call_meta_by_call_id(%{call_id: call_id}) do
    CallMeta
    |> where([cm], cm.call_id == ^call_id and cm.admin == false)
    |> select([cm], %{call_id: cm.call_id, status: cm.status, admin: cm.admin})
    |> Repo.all()
  end

  def get_received_call_meta_by_call_id(call_id) do
    CallMeta
    |> where([cm], cm.call_id == ^call_id and cm.admin == false and cm.status == "received")
    |> select([cm], %{
      participant_id: cm.participant_id,
      status: cm.status,
      call_start_time: cm.call_start_time
    })
    |> Repo.all()
  end

  def get_ended_call_meta_by_call_id(call_id, participant_id) do
    CallMeta
    |> where(
      [cm],
      cm.participant_id == ^participant_id and cm.call_id == ^call_id and cm.status == "ended"
    )
    |> select([cm], %{
      participant_id: cm.participant_id,
      status: cm.status,
      call_start_time: cm.call_start_time,
      call_end_time: cm.call_end_time,
      call_duration: cm.call_duration
    })
    |> limit(1)
    |> Repo.one()
  end

  def get_group_id_by_call_id(call_id) do
    Call
    |> where([c], c.id == ^call_id)
    |> select([c], %{group_id: c.group_id})
    |> limit(1)
    |> Repo.one()
  end

  def get_call_meta(call_id) do
    CallMeta
    |> where([cm], cm.call_id == ^call_id)
    |> Repo.all()
  end

  def get_calls(user_id) do
    Call
    |> where([cm], cm.initiator_id == ^user_id)
    |> Repo.all()
  end
end
