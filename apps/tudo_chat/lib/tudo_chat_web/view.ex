defmodule TudoChatWeb.View do
  @moduledoc """
  A module that has common helper functions for controllers,
  views and so on.

  This can be used in your application as:

      use Qber.Common, :controller
      use Qber.Common, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  @doc false
  defmacro __using__(_options) do
    quote do
      @skip_keys [:__meta__, :password, :hashword, :user_id, :app_name]

      def render("records.json", %{conn: conn, data: records, envelop: envelop, meta: meta}) do
        records_object =
          records
          |> Enum.map(fn record -> prepare(conn, record) end)
          |> wrap(envelop)

        Map.put(records_object, :meta, meta)
      end

      def render("records.json", %{conn: conn, data: records, envelop: envelop}) do
        records
        |> Enum.map(fn record -> prepare(conn, record) end)
        |> wrap(envelop)
      end

      def render("record.json", %{conn: conn, data: record, envelop: envelop, meta: meta}) do
        record_object =
          prepare(conn, record)
          |> wrap(envelop)

        if is_map(meta) do
          Map.put(record_object, :meta, meta)
        else
          record_object
        end
      end

      def render("record.json", %{conn: conn, data: record, envelop: envelop}) do
        prepare(conn, record)
        |> wrap(envelop)
      end

      def wrap(response, envelop \\ @singular) do
        %{envelop => response}
      end

      def to_map(data) do
        if(Map.has_key?(data, :__struct__), do: Map.from_struct(data), else: data)
      end

      @doc """
        prepare/2

        TODO: check for nested associations
      """

      def prepare(conn, data) do
        filter = fn {key, val} ->
          cond do
            key in [:__meta__] ->
              false

            # is_map(val) -> Ecto.assoc_loaded?(val)
            is_map(val) ->
              Ecto.assoc_loaded?(val)

            key not in @skip_keys ->
              true

            true ->
              false
          end
        end

        data
        |> to_map
        |> Enum.filter(filter)
        |> Enum.into(%{})
      end

      defoverridable prepare: 2
    end
  end
end
