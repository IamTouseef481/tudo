defmodule TudoChatWeb.Utils.Number do
  @moduledoc false

  def parse(value) do
    val =
      case !is_number(value) && Integer.parse(value) do
        {val, ""} -> val
        {_val, _whatever} -> :error
        false -> value
        :error -> :error
      end

    case val == :error && Float.parse(value) do
      {val, _whatever} -> val
      false -> val
      :error -> :error
    end
  end
end
