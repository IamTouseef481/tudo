defmodule TudoChat.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias TudoChat.Repo

  alias TudoChat.Channels.Channel
  @prefix "tudo_"

  def list_channels do
    Channel
    |> Repo.all(prefix: Triplex.to_prefix(@prefix))
  end

  def get_channel!(id), do: Repo.get!(Channel, id)

  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert(prefix: Triplex.to_prefix(@prefix))
  end

  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  def change_channel(%Channel{} = channel) do
    Channel.changeset(channel, %{})
  end
end
