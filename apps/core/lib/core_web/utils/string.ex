defmodule CoreWeb.Utils.String do
  @moduledoc false

  def dasherize(str) do
    str
    |> Inflex.underscore()
    |> String.replace("_", "-")
  end

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.split("")

  def string_of_length(length \\ 10) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end

  def generate_random_password do
    characters = [
      {1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ"},
      {2, "abcdefghijklmnopqrstuvwxyz"},
      {1, "@#%!$%^&*"},
      {4, "0123456789"}
    ]

    Enum.reduce(characters, [], fn {length, options}, acc ->
      [custom_string_of_length(options, length) | acc]
    end)
    |> Enum.shuffle()
    |> Enum.join("")
  end

  def custom_string_of_length(available_chars, length \\ 1) do
    available_chars =
      available_chars
      |> String.split("")
      |> List.delete_at(0)
      |> List.delete_at(-1)

    Enum.reduce(1..length, [], fn _, acc ->
      [Enum.random(available_chars) | acc]
    end)
    |> Enum.join("")
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
