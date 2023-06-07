defmodule TudoChatWeb.GraphQL.Types.UserType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :user_type do
    field(:id, :id)
    field(:business_id, :integer)
    field(:confirmation_sent_at, :datetime)
    field(:confirmation_token, :string)
    field(:confirmed_at, :datetime)
    field(:current_sign_in_at, :datetime)
    field(:email, :string)
    field(:failed_attempts, :integer)
    field(:is_verified, :boolean)
    field(:locked_at, :datetime)
    field(:mobile, :string)
    field(:password_hash, :string)
    field(:password, :string)
    field(:password_confirmation, :string)
    field(:platform_terms_and_condition_id, :integer)
    field(:profile, :json)
    field(:reset_password_sent_at, :datetime)
    field(:reset_password_token, :string)
    field(:scopes, :string)
    field(:sign_in_count, :integer)
    field(:unlock_token, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:profile_image, :json)
  end

  input_object :user_input_type do
    field :email, non_null(:string)
    field :password, non_null(:string)
    field :password_confirmation, non_null(:string)
  end
end
