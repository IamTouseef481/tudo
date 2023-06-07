defmodule CoreWeb.GraphQL.Types.CustomTypes do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  scalar :dynamic, name: "Dynamic" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  scalar :json, name: "Json" do
    serialize(&encode/1)
    parse(&decode/1)
  end

  scalar :epoch, name: "Epoch" do
    description("""
    Epoch
    """)

    serialize(&epoch_encode/1)
    parse(&epoch_decode/1)
  end

  @spec decode(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
  @spec decode(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
    case Jason.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end

  defp decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode(_) do
    :error
  end

  defp encode(value), do: value

  @spec epoch_decode(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
  @spec epoch_decode(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp epoch_decode(%Absinthe.Blueprint.Input.String{value: value}), do: {:ok, value}

  defp epoch_decode(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp epoch_decode(_) do
    :error
  end

  defp epoch_encode(value) do
    value |> Date.from_erl()
  end
end
