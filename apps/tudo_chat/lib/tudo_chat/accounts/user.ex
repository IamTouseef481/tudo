defmodule TudoChat.Accounts.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :business_id, :integer
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
    field :password_confirmation, :string, virtual: true
    field :platform_terms_and_condition_id, :integer
    field :profile, :map
    field :reset_password_sent_at, :utc_datetime
    field :reset_password_token, :string
    field :scopes, :string
    field :sign_in_count, :integer, default: 0
    field :unlock_token, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :mobile,
      :password,
      :password_confirmation,
      :is_verified,
      :profile,
      :reset_password_token,
      :reset_password_sent_at,
      :failed_attempts,
      :sign_in_count,
      :current_sign_in_at,
      :locked_at,
      :unlock_token,
      :confirmation_token,
      :confirmed_at,
      :confirmation_sent_at,
      :platform_terms_and_condition_id,
      :business_id,
      :scopes
    ])
    |> validate_required([:email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase(&1))
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> unique_constraint(:mobile)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp hash_password(changeset) do
    changeset
  end
end
