defmodule TudoChat.Messages.MessageMeta do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages_meta" do
    field :deleted, :boolean, default: false
    field :favourite, :boolean, default: false
    field :liked, :boolean, default: false
    field :sent, :boolean, default: false
    field :read, :boolean, default: false
    field :user_id, :integer
    belongs_to :message, TudoChat.Messages.ComGroupMessage

    timestamps()
  end

  @doc false
  def changeset(message_meta, attrs) do
    message_meta
    |> cast(attrs, [:liked, :deleted, :favourite, :sent, :read, :user_id, :message_id])
    |> validate_required([:user_id, :message_id])
  end
end
