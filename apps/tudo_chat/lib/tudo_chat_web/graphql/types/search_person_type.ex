defmodule TudoChatWeb.GraphQL.Types.SearchPersonType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  object :search_person_type do
    field(:id, :id)
    field(:email, :string)
    field(:mobile, :string)
    field(:token, :string)
    field(:status_id, :string)
    field(:acl_role_id, list_of(:string))
    field(:is_bsp, :boolean)
    field(:platform_terms_and_condition_id, :integer)
    field(:is_verified, :boolean)
    field(:profile, :json)
    #    field :availability, :json
    field(:scopes, :string)
    field(:birth_at, :string)
    field(:address, :string)
    field(:gender, :string)
    field(:confirmation_token, :string)
    field(:unlock_token, :string)
    field(:sign_in_count, :integer)
    field(:failed_attempts, :integer)
    field(:reset_password_token, :string)
    field(:reset_password_sent_at, :datetime)
    field(:confirmation_sent_at, :datetime)
    field(:confirmed_at, :datetime)
    field(:current_sign_in_at, :datetime)
    #    field :language, :language_type, resolve: assoc(:language)
    #    field :country, :country_type, resolve: assoc(:country)
    field(:locked_at, :datetime)
    #    field(:meta, :json)
    #    field :user_address, list_of(:user_address_type), resolve: assoc(:user_address)
    #    field :install, :user_installs_type
  end

  input_object :search_person_input_type do
    field :email, :string
    field :name, :string
    field :mobile, :string
  end
end
