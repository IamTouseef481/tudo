defmodule Core.Schemas.Business do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Branch, User, UserStatuses}

  schema "businesses" do
    field :name, :string
    field :description, :string
    field :phone, :string
    field :agree_to_pay_for_verification, :boolean, default: false
    field :is_verified, :boolean, default: false
    field :is_active, :boolean, default: false
    field :settings, :map
    field :rating, :float
    field :rating_count, :integer
    field :employees_count, :integer
    field :terms_and_conditions, {:array, :integer}
    field :profile_pictures, {:array, :map}
    belongs_to :user, User
    belongs_to :status, UserStatuses, type: :string
    has_many :branches, Branch
    timestamps()
  end

  @doc false
  def changeset(business, %{employees_count: _} = attrs) do
    business
    |> cast(attrs, [
      :user_id,
      :description,
      :name,
      :phone,
      :agree_to_pay_for_verification,
      :is_verified,
      :is_active,
      :settings,
      :rating,
      :rating_count,
      :employees_count,
      :terms_and_conditions,
      :profile_pictures,
      :status_id
    ])
    |> validate_required([
      :user_id,
      :name,
      :agree_to_pay_for_verification,
      :is_active,
      :settings,
      :employees_count,
      :terms_and_conditions
    ])
  end

  def changeset(business, attrs) do
    business
    |> cast(attrs, [
      :user_id,
      :description,
      :name,
      :phone,
      :agree_to_pay_for_verification,
      :is_verified,
      :is_active,
      :settings,
      :rating,
      :rating_count,
      :employees_count,
      :terms_and_conditions,
      :profile_pictures,
      :status_id
    ])
    |> validate_required([
      :user_id,
      :name,
      :agree_to_pay_for_verification,
      :is_active,
      :settings,
      :terms_and_conditions
    ])
  end
end
