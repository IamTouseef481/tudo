# credo:disable-for-this-file
defmodule Environment do
  @moduledoc """
  This modules provides various helpers to handle environment metadata
  """

  def get(key, default \\ nil), do: System.get_env(key, default)

  def get!(key), do: System.fetch_env!(key)

  def get_boolean(key) do
    case get(key) do
      "true" -> true
      "1" -> true
      _ -> false
    end
  end

  def get_integer(key, default \\ nil) do
    case get(key) do
      value when is_bitstring(value) -> String.to_integer(value)
      _ -> default
    end
  end

  def get_cors_origins do
    case Environment.get("CORS_ALLOWED_ORIGINS") do
      origins when is_bitstring(origins) ->
        origins
        |> String.split(",")
        |> case do
          [origin] -> origin
          origins -> origins
        end

      _ ->
        nil
    end
  end

  def get_list(env_key, default \\ []) do
    case Environment.get(env_key) do
      items when is_bitstring(items) and byte_size(items) > 0 ->
        String.split(items, ",")

      _ ->
        default
    end
  end

  def get_endpoint_url_config(nil), do: nil
  def get_endpoint_url_config(""), do: nil

  def get_endpoint_url_config(uri) do
    [
      host: uri.host,
      scheme: uri.scheme,
      port: uri.port
    ]
  end

  def get_uri_part(%URI{host: host}, :host), do: host
  def get_uri_part(%URI{port: port}, :port), do: port
  def get_uri_part(%URI{scheme: scheme}, :scheme), do: scheme

  def get_uri_part(%URI{userinfo: userinfo}, :user) when is_binary(userinfo) do
    case String.split(userinfo, ":") do
      [user | _rest] -> user
      _ -> nil
    end
  end

  def get_uri_part(%URI{path: <<"/", path::binary>>}, :database), do: path

  def get_uri_part(_, _), do: nil

  def get_safe_uri(nil), do: nil
  def get_safe_uri(""), do: nil
  def get_safe_uri(url), do: URI.parse(url)

  def get_quantum_state(var), do: if(get_boolean(var), do: :active, else: :inactive)

  def filter_oban_queues(queues) do
    queues
    |> Enum.filter(fn
      {_queue_name, queue_concurrency} when is_integer(queue_concurrency) ->
        queue_concurrency > 0

      {_queue_name, opts} ->
        global_limit = Keyword.get(opts, :global_limit, 0)
        local_limit = Keyword.get(opts, :local_limit, 0)
        # either global or local should exist and be > 0
        if global_limit > 0 or local_limit > 0 do
          true
        else
          false
        end
    end)
    |> Enum.to_list()
  end

  def extend_oban_queue_with_rate_limit(queue_concurrency) do
    [global_limit: queue_concurrency, rate_limit: [allowed: queue_concurrency, period: 1]]
  end
end
