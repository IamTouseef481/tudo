defmodule TudoChat.Messages.ComGroupMessage do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Groups.Group

  schema "com_group_messages" do
    field :content_type, :string
    field :is_active, :boolean, default: false
    field :is_personal, :boolean, default: false
    field :forwarded, :boolean, default: false
    field :message, :string
    field :message_file, :map
    field :user_from_id, :integer
    field :user_to_id, :integer
    field :parent_message_id, :integer
    field :tagged_user_ids, {:array, :integer}
    field :created_at, :utc_datetime
    belongs_to :job_status, TudoChat.Messages.JobStatus, type: :string
    belongs_to :group, Group
    has_many :message_meta, TudoChat.Messages.MessageMeta, foreign_key: :message_id
    # has_one :message_tags, TudoChat.Tags.Tag
    #    belongs_to :user_from, User
    #    belongs_to :user_to, User
    timestamps()
  end

  @doc false
  def changeset(com_group_message, attrs) do
    com_group_message
    |> cast(attrs, [
      :content_type,
      :message,
      :is_active,
      :is_personal,
      :forwarded,
      :group_id,
      :user_from_id,
      :user_to_id,
      :parent_message_id,
      :message_file,
      :job_status_id,
      :created_at,
      :tagged_user_ids
    ])
    |> validate_required([:group_id])
  end
end
