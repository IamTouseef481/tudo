defmodule TudoChatWeb.Utils.String do
  @moduledoc false

  def dasherize(str) do
    str
    |> Inflex.underscore()
    |> String.replace("_", "-")
  end

  #  def pluralize(str) do
  #    Menu is fixed in inflex git repo so update this function and remove this method
  #    case str
  #         |> String.split("-") do
  #      ["menu" | []] ->
  #        "menus"
  #
  #      [head | []] ->
  #        Inflex.pluralize(head)
  #
  #      parts ->
  #        [head | tail] = Enum.reverse(parts)
  #        Enum.join(Enum.reverse(tail), "-") <> "-" <> Inflex.pluralize(head)
  #    end
  #  end
end
