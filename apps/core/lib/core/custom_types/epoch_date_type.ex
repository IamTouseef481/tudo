defmodule Core.CustomTypes.EpochDateType do
  @moduledoc false
  use Ecto.Type

  def type, do: Ecto.Type

  def cast(dt) when is_integer(dt) do
    Date.to_erl(dt) |> cast()
  end

  def cast(datetime), do: cast(datetime)

  def load(datetime), do: load(datetime)

  def dump(datetime), do: dump(datetime)
end
