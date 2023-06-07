defmodule TudoChatWeb.Controller do
  # use Qber.Web, :base_controller
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
    quote location: :keep do
      @default_page_opts %{"skip" => 0, "limit" => 10}
      @envelopables [:create, :update]
      alias Qber.User.Service, as: UserService
      import Ecto.Query
      plug(:put_view, @view)
      plug(:scrub_params, @singular when var!(action) in @envelopables)

      def success(conn, data, view \\ "record.json") do
        %{model_data: model_data, meta: meta} = get_model_data(data)
        list = is_list(model_data)
        envelop = if(list, do: @plural, else: @singular)
        tpl = if(list, do: "records.json", else: "record.json")

        conn
        |> put_view(@view)
        |> render(tpl, %{data: model_data, envelop: envelop, meta: meta})
      end

      defp get_model_data(data) do
        case data do
          %{data: data, meta: meta} ->
            %{model_data: data, meta: meta}

          _ ->
            %{model_data: data, meta: nil}
        end
      end

      def error(conn, changeset, status \\ :unprocessable_entity) do
        if status == :unprocessable_entity do
          conn
          |> put_status(status)
          |> put_view(@error_view)
          |> render("error.json", %{changeset: changeset})
        else
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(@error_view)
          |> render("error.json", %{changeset: changeset, status: status})
        end
      end

      defoverridable success: 2,
                     error: 2
    end
  end
end
