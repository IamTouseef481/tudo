defmodule Core.Schemas.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Countries, Languages, UserStatuses}

  #  @password_exp ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W])[A-Za-z\d\W]{6,16}$/

  #  @mail_exp ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

  schema "users" do
    field :is_bsp, :boolean, default: false
    field :confirmation_sent_at, :utc_datetime
    field :confirmation_token, :string
    field :confirmed_at, :utc_datetime
    field :current_sign_in_at, :utc_datetime
    field :email, :string
    field :failed_attempts, :integer
    field :is_verified, :boolean, default: false
    field :locked_at, :utc_datetime
    field :mobile, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :platform_terms_and_condition_id, :integer
    field :profile, :map
    field :availability, :map
    field :birth_at, :string
    field :address, :string
    field :gender, :string
    field :reset_password_sent_at, :utc_datetime
    field :deleted_at, :utc_datetime
    field :reset_password_token, :string
    field :sign_in_count, :integer, default: 0
    field :scopes, :string
    field :referral_code, :string
    field :refresh_token, :string
    field :unlock_token, :string
    field :rating, :float, default: 5.0
    field :rating_count, :integer, default: 0
    field :profile_public, :boolean, default: true
    field :acl_role_id, {:array, :string}
    belongs_to :language, Languages
    belongs_to :country, Countries
    belongs_to :status, UserStatuses, type: :string
    has_many :user_address, Core.Schemas.UserAddress
    has_many :user_installs, Core.Schemas.UserInstalls
    has_one :cashfree_beneficiary, Core.Schemas.CashfreeBeneficiary
    #    belongs_to :acl_role, AclRole, [type: :string]

    timestamps()
  end

  @all_fields [
    :birth_at,
    :address,
    :gender,
    :acl_role_id,
    :country_id,
    :language_id,
    :status_id,
    :email,
    :mobile,
    :password_hash,
    :password,
    :is_verified,
    :profile,
    :referral_code,
    :availability,
    :reset_password_token,
    :reset_password_sent_at,
    :failed_attempts,
    :sign_in_count,
    :current_sign_in_at,
    :locked_at,
    :unlock_token,
    :rating,
    :rating_count,
    :confirmation_token,
    :confirmed_at,
    :confirmation_sent_at,
    :platform_terms_and_condition_id,
    :is_bsp,
    :scopes,
    :profile_public,
    :deleted_at,
    :refresh_token
  ]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @all_fields)
    |> validate_required([
      :country_id,
      :language_id,
      :status_id,
      :email,
      :mobile,
      :is_verified,
      :profile,
      :confirmation_sent_at
    ])
    #    |> validate_format(:email,@mail_exp)
    #    |> validate_length(:password, min: 6)
    #    |> validate_format(:password, @password_exp)
    #    |> validate_length(:mobile, min: 10)
    #    |> validate_format(:mobile, ~r/^[+]+[0-9()-]{10,18}$/)
    |> update_change(:email, &String.downcase(&1))
    |> unique_constraint(:email)
    |> hash_password
  end

  def invite_changeset(user, attrs) do
    user
    |> cast(attrs, @all_fields)
    |> validate_required([
      :status_id,
      :email
    ])
    |> update_change(:email, &String.downcase(&1))
    |> unique_constraint(:email)
  end

  def forget_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    #    |> validate_format(:email,@mail_exp)
    #    |> validate_length(:password, min: 6)
    #    |> validate_format(:password, @password_exp)
    |> update_change(:email, &String.downcase(&1))
    |> unique_constraint(:email)
    |> unique_constraint(:mobile)
    |> hash_password
  end

  defp hash_password(
         %Ecto.Changeset{valid?: true, changes: %{password: password, email: email}} = changeset
       ) do
    changeset = put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
    put_change(changeset, :confirmation_token, Argon2.hash_pwd_salt(email))
  end

  defp hash_password(changeset) do
    changeset
  end
end
