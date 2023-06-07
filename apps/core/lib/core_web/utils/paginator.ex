defmodule CoreWeb.Utils.Paginator do
  @moduledoc false

  def make_pagination_params do
    Application.get_env(:core, :scrivener)
    |> Scrivener.Config.new()
    |> add_params()
  end

  def get_config(params) do
    page_number = params[:page_number] || 1
    page_size = params[:page_size] || 10

    config =
      Application.get_env(:core, :scrivener)
      |> Scrivener.Config.new()

    %{config | page_number: page_number, page_size: page_size}
  end

  def add_params(config) do
    config =
      case Application.get_env(:core, :page_size) do
        nil -> config
        size -> %{config | page_size: size}
      end

    case Application.get_env(:core, :page_number) do
      nil -> config
      page_number -> %{config | page_number: page_number}
    end
  end
end
