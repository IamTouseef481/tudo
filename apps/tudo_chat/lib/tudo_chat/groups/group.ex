defmodule TudoChat.Groups.Group do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Groups.{GroupMember, GroupStatus, GroupType}
  alias TudoChat.Messages.ComGroupMessage

  schema "groups" do
    field :add_members, :boolean, default: false
    field :allow_pvt_message, :boolean, default: false
    field :editable, :boolean, default: false
    field :public, :boolean, default: false
    field :forward, :boolean, default: false
    field :name, :string
    field :profile_pic, :map
    field :reference_id, :integer
    field :service_request_id, :integer
    field :bid_id, :integer
    field :proposal_id, :integer
    field :created_by_id, :integer
    field :created_at, :utc_datetime
    field :last_message_at, :utc_datetime
    field :branch_id, :integer
    field :link, :string
    field :marketing_group, :boolean, default: false
    belongs_to :group_type, GroupType, type: :string
    belongs_to :group_status, GroupStatus, type: :string
    has_many :group_members, GroupMember
    has_one :last_message, ComGroupMessage
    has_one :unread_message_count, ComGroupMessage

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :name,
      :public,
      :reference_id,
      :service_request_id,
      :editable,
      :forward,
      :add_members,
      :allow_pvt_message,
      :profile_pic,
      :marketing_group,
      :last_message_at,
      :created_by_id,
      :group_type_id,
      :group_status_id,
      :bid_id,
      :proposal_id,
      :created_at,
      :branch_id,
      :link
    ])
    |> validate_required([:name, :created_by_id, :group_type_id])
    |> handle_last_message_at
  end

  def handle_last_message_at(%{changes: changes} = changeset) do
    if Map.has_key?(changes, :last_message_at) do
      changeset
    else
      changeset
      |> put_change(:last_message_at, DateTime.utc_now() |> DateTime.truncate(:second))
    end
  end
end
