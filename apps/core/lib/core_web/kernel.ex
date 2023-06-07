defmodule CoreWeb.Kernel do
  @moduledoc false

  def get_error_view do
    Application.get_env(:core, CoreWeb.Endpoint)[:render_errors][:view]
  end

  defmacro __using__(_options) do
    quote do
      me =
        __MODULE__
        |> to_string

      re = ~r(Controller$|Model$|View$|Agent$|Helper$|Service$|Enum$|Docs$)

      @umbral_module Regex.replace(re, me, "")
      @nameparts @umbral_module
                 |> String.split(".")
      @module @nameparts |> Enum.join(".")
      @myname @nameparts
              |> List.last()
      @swagger_schema @myname
                      |> String.to_atom()
      @swagger_schema_by (@myname <> "By")
                         |> String.to_atom()
      @swagger_schema_list (@myname <> "List")
                           |> String.to_atom()
      @singular @myname
                |> CoreWeb.Utils.String.dasherize()
                |> String.downcase()
      @plural @singular
              |> Inflex.pluralize()
      @endpoint ~s(/#{@plural})
      @view (@module <> "View")
            |> String.to_atom()
      @controller (@module <> "Controller")
                  |> String.to_atom()

      @error_view CoreWeb.Kernel.get_error_view()
    end
  end
end
