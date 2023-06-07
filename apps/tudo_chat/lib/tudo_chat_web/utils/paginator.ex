defmodule TudoChatWeb.Utils.Paginator do
  @moduledoc false
  def make_pagination_params do
    Application.get_env(:tudo_chat, :scrivener)
    |> Scrivener.Config.new()
    |> add_params()
  end

  def add_params(config) do
    config =
      case Application.get_env(:tudo_chat, :page_size) do
        nil -> config
        size -> %{config | page_size: size}
      end

    case Application.get_env(:tudo_chat, :page_number) do
      nil -> config
      page_number -> %{config | page_number: page_number}
    end
  end
end
