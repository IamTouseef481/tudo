defmodule TudoChatWeb.Utils.Paginate do
  @moduledoc false

  import Ecto.Query
  alias TudoChat.Repo

  defstruct [:data, :meta]

  @min_limit 0
  @min_skip 0
  @default_skip 0

  def new(query, params) do
    {skip, params} = get_skip_value(params)
    {limit, _params} = get_limit_value(params)

    %{
      data: data(query, skip, limit),
      meta: meta(query, skip, limit)
    }
  end

  defp get_skip_value(params) do
    {skip, params} = Keyword.pop(params, :skip, @min_skip)
    skip = to_int(skip)
    skip = if skip > @default_skip, do: skip, else: @default_skip
    {skip, params}
  end

  def get_limit(limit_param) do
    limit = to_int(limit_param || Application.get_env(:TudoChat, :query)[:default_limit])
    limit = if limit > @min_limit, do: limit, else: @min_limit
    max_limit = Application.get_env(:TudoChatWeb, :query)[:max_limit]
    if limit > max_limit, do: max_limit, else: limit
  end

  defp get_limit_value(params) do
    {limit, params} =
      Keyword.pop(params, :limit, Application.get_env(:TudoChat, :query)[:default_limit])

    limit = to_int(limit)
    limit = if limit > @min_limit, do: limit, else: @min_limit
    max_limit = Application.get_env(:TudoChatWeb, :query)[:max_limit]
    limit = if limit > max_limit, do: max_limit, else: limit
    {limit, params}
  end

  defp meta(query, skip, limit) do
    %{
      skip: skip,
      limit: limit,
      count: count(query)
    }
  end

  defp data(query, skip, limit) do
    query
    |> limit([q], ^limit)
    |> offset([q], ^skip)
    |> Repo.all()
  end

  defp count(query) do
    queryable =
      query
      |> exclude(:order_by)
      |> exclude(:preload)
      |> exclude(:select)

    # queryable =
    #   case EASY.Helper.field_exists?(queryable, :deleted_at) do
    #     false ->
    #       queryable

    #     true ->
    #       from(p in queryable, where: is_nil(p.deleted_at))
    #   end

    queryable
    |> select([e], count(e.id))
    |> Repo.one()
  end

  defp to_int(i) when is_integer(i), do: i

  defp to_int(s) when is_binary(s) do
    case Integer.parse(s) do
      {i, _} -> i
      :error -> :error
    end
  end
end
