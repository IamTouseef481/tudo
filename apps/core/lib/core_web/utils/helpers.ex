defmodule CoreWeb.Utils.Helpers do
  @moduledoc false

  @spec abort(any(), any(), any()) :: atom()
  def abort(_, _, _), do: :abort

  @doc """
    sends response for the Ecto.all, and list responses.
    In mode: :reverse we are doing to inverse of response like '[]'  will indicate success and '[struct]' will indicate error.

  ##Examples
    `some_query |> repo.all`
       this will return `[]` or `[structs]`  so we can handle that response as
      'if '[]' or '[structs]', do:some_query |> repo.all |> default_resp()'
      'if '[]', do: some_query |> repo.all |> default_resp(msg: error_msg)'
      'if '[]', do: some_query |> repo.all |> default_resp(mode: :reverse,msg: success_msg)'
      'if '[structs]', do: some_query |> repo.all |> default_resp(mode: :reverse,msg: error_msg)'

    merges transactions of a sage.

  ##Examples

    `defp create_employee_sage(input) do
      new()
      |> run(:employee, &create_employee/2, &abort/3)
      |> run(:salary, &create_salary/2, &abort/3)
      |> transaction(MyApp.Repo, input)
    end`

      and we like to merge two transactions like employee data and its salary as
     `{:ok, _, result} |> default_resp(in: salary, [employee: employee])`

     gets data from transactions of a sage.

  ##Examples

    'defp create_employee_sage(input) do
      new()
      |> run(:employee, &create_employee/2, &abort/3)
      |> run(:salary, &create_salary/2, &abort/3)
      |> transaction(MyApp.Repo, input)
    end'

      and we can to get employee as
     `{:ok, _, result} |> default_resp(key: employee)`

      sends response for the Ecto.insert_all,Ecto.insert_all and Ecto.insert_all.
    In mode: :reverse we are doing to inverse of response like '{integer,nil}'  will indicate success and '{integer,[structs]}' will indicate error.

  ##Examples

    `some_query |> repo.insert_all`
       this will return `{integer,nil}` or `{integer,[structs]}`  so we can handle that response as
      'if '{integer,nil} or {integer,[structs]}', do:some_query |> repo.insert_all |> default_resp()'
      'if '{integer,nil}', do: some_query |> repo.insert_all |> default_resp(msg: error_msg)'
      'if '{integer,nil}', do: some_query |> repo.insert_all |> default_resp(mode: :reverse,msg: success_msg)'
      'if '{integer,[structs]}', do: some_query |> repo.insert_all |> default_resp(mode: :reverse,msg: error_msg)'

      sends response for the changeset errors in functions  Ecto.insert , Ecto.update,Ecto.delete.

  ##Examples

    `some_query |> repo.insert`
       this will return `{:ok,struct}` or `{:error,changeset}`  so we can handle that response as
      'if '{:error,changeset}', do: some_query |> repo.insert |> default_resp()'

      sends response for the Ecto.get, Ecto.get_by,Ecto.one and functions that will return nil or struct.
    Also works for Ecto.insert ,Ecto.update and Ecto.delete.
    In mode: :reverse we are doing to inverse of response like 'nil'  will indicate success and 'struct' will indicate error.

  ##Examples

    `some_query |> repo.get`
       this will return `nil` or `struct`  so we can handle that response as

      'if 'nil or struct', do:some_query |> repo.get |> default_resp()'
      'if 'nil or struct', do: some_query |> repo.insert_all |> default_resp(mode: :reverse)'

    `some_query |> repo.create`
       this will return `{:ok,struct}` or ;{:error,changeset}'  so we can handle that response as

      'some_query |> repo.insert |> default_resp()'
      'some_query |> repo.update |> default_resp()'
      'some_query |> repo.delete |> default_resp()'

     default_resp returns tuple as

       'result |> default_resp()' Returns {:ok,result}
       'default_resp(mode: :reverse,msg: error)' Returns {:error,error}
       'params |> default_resp()' Returns {:ok, params}

    send custom data instead of error message
    in case of nil i want to return something custom
      repo.get() |> default_resp(mode: custom, any: :any_data)

  """
  @spec default_resp(any(), Keyword.t()) :: tuple()
  def default_resp(result, opts \\ [])

  def default_resp([], mode: :reverse, msg: msg), do: msg |> ok()

  def default_resp([], msg: err), do: err |> error()

  def default_resp([result], _), do: result |> ok()

  def default_resp([], mode: :custom, any: _, msg: err), do: err |> error()

  def default_resp(result, mode: :custom, any: any, msg: _) when is_list(result), do: any |> ok()

  def default_resp(result, mode: :reverse, msg: err) when is_list(result), do: err |> error()

  def default_resp(result, _) when is_list(result), do: result |> ok()

  def default_resp([], _), do: error()

  def default_resp({:ok, _, result}, in: in_, keys: keys) when is_map(result) do
    in_ = result[in_]

    case is_map(in_) do
      true ->
        Enum.reduce(keys, in_, fn {key, value}, acc -> put(acc, value, result[key]) end) |> ok()

      false ->
        result[in_]
    end
  end

  def default_resp({:ok, _, result}, key: key) when is_map(result),
    do: result |> Map.get(key) |> ok

  def default_resp({_, nil}, mode: :reverse, msg: msg), do: msg |> ok()

  def default_resp({_, nil}, msg: err), do: err |> error()

  def default_resp({_, nil}, _), do: error()

  def default_resp({_, result}, msg: msg) when is_list(result), do: msg |> ok()

  def default_resp({:ok, result}, _) when is_list(result), do: result |> ok()

  def default_resp({:error, result}, _) when is_list(result), do: result |> error()

  def default_resp({:error, changeset}, _) when is_struct(changeset),
    do: changeset_error(changeset)

  def default_resp({:error, _}, mode: :custom, any: any), do: any |> error()

  def default_resp({:error, _}, mode: :custom, default: false, any: any), do: any |> error()

  def default_resp({:ok, result}, mode: :custom, default: false, any: _), do: result

  def default_resp(result, _) when is_tuple(result), do: result

  def default_resp(result, mode: :reverse) when is_nil(result), do: result |> ok()

  def default_resp(result, msg: err) when is_nil(result), do: err |> error()

  def default_resp(result, _) when is_nil(result), do: result |> error()

  def default_resp({_, result}, msg: msg) when is_list(result), do: msg |> ok()

  def default_resp({_, result}, _) when is_list(result), do: result |> ok()

  def default_resp(_, mode: :reverse, msg: err), do: err |> error

  def default_resp(result, mode: :reverse), do: result |> error()

  def default_resp(result, mode: :custom, default: true), do: result

  def default_resp(result, _), do: result |> ok()

  @spec changeset_error(struct()) :: tuple()
  def changeset_error(%Ecto.Changeset{errors: errors}) do
    {key, {msg, _}} = List.first(errors)
    {:error, "#{key} #{msg}"}
  end

  def changeset_error(err), do: err |> error()

  @doc """
    sends ok tuple.
  ##Examples
      'result |> ok()' Returns {:ok, result}
  """
  @spec ok(any()) :: tuple()
  def ok(data) when is_tuple(data), do: data

  def ok(data), do: {:ok, data}

  @doc """
    sends error tuple.

  ##Examples

      ```elixir
        iex> error |> error()
        {:error, error}
      ```
  """
  @spec error(any()) :: tuple()
  def error(data \\ "Doesn't Exist!")

  def error(data) when is_tuple(data), do: data

  def error(nil), do: {:error, "Doesn't Exist!"}

  def error(err), do: {:error, err}

  @doc """
    sends :cont tuple.

  ##Examples

      ```elixir
        Enum.reduce_while(1..5, 0, fn x, acc -> x + acc |> continue end)
        {:cont, value}
      ```
  """
  def continue(data), do: {:cont, data}

  @doc """
    sends :halt tuple.

  ##Examples

      ```elixir
        Enum.reduce_while(1..5, 0, fn x, acc -> x + acc |> halt end)
        {:halt, value}
      ```
  """
  def halt(data), do: {:halt, data}

  @doc """
    put value in map

  ##Examples

      ```elixir
        iex> map = %{a: 1, b: 2, c: 3}
        iex> map |> put(:d, 4)
        %{a: 1, b: 2, c: 3, d: 4}
      ```
  """
  @spec put(map(), atom(), any()) :: map()
  def put(map, key, value), do: map |> Map.put(key, value)

  @doc """
    pass custom params to next pipe line in-case you don't want to send
    the results of current scope

  ##Examples
      ```elixir
        iex> id = 1
        id
        |> fetch_results()
        |> then(fn results -> do_something_with_results |> pass(id) end)
      ```
  """
  @spec pass(any(), any(), Keyword.t()) :: any()
  def pass(_, _, opts \\ [])

  def pass(_, value, with: :ok), do: value |> ok()

  def pass(_, value, _), do: value

  @doc """
    get value or values from map

  ##Examples

      ```elixir
        iex> map = [%{a: 1, b: 2, c: 3}, %{a: 4, b: 5, c: 6}]
        iex> map |> get(:a)
        [1, 4]
        iex> map = %{a: 1, b: 2, c: 3}
        iex> map |> get(:a)
        1
        iex> map |> get(:d)
        nil
      ```
  """
  def get(list, key) when is_list(list), do: list |> Enum.map(&(&1 |> get(key)))

  def get(map, key) when is_map(map), do: map |> Map.get(key)

  @doc """
      add time structs

    ##Examples

      ```elixir
        iex> add(~T[01:00:00], ~T[02:00:00])
        ~T[03:00:00]
      ```
  """
  @spec add(Calendar.time(), Calendar.time()) :: Calendar.time()
  def add(a, b) do
    {h, m, s} = a |> Time.to_erl()
    {h_, m_, s_} = b |> Time.to_erl()
    {hr, min, sec} = {h + h_, m + m_, s + s_}
    updated_sec = if sec >= 60, do: sec - 60, else: sec
    min = validate_time(min, sec)
    updated_min = if min >= 60, do: min - 60, else: min
    hr = validate_time(hr, min)
    Time.from_erl!({hr, updated_min, updated_sec})
  end

  defp validate_time(tx, t), do: if(t >= 60, do: tx + 1, else: tx)
end
