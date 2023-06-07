defmodule CoreWeb.GraphQL.Types.UserType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :user_type do
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
    field(:referral_code, :string)
    field(:confirmation_token, :string)
    field(:unlock_token, :string)
    field(:sign_in_count, :integer)
    field(:failed_attempts, :integer)
    field(:rating, :float)
    field(:rating_count, :integer)
    field(:reset_password_token, :string)
    field(:reset_password_sent_at, :datetime)
    field(:confirmation_sent_at, :datetime)
    field(:confirmed_at, :datetime)
    field(:current_sign_in_at, :datetime)
    field(:profile_public, :boolean)
    field :language, :language_type, resolve: assoc(:language)
    field :country, :country_type, resolve: assoc(:country)
    field(:locked_at, :datetime)
    field(:meta, :json)
    field :user_address, list_of(:user_address_type), resolve: assoc(:user_address)
    field :install, :user_installs_type
    #    field :user_address, list_of(:user_address_type)
  end

  object :user_address_type do
    field :id, :integer
    field :address, :string
    field :primary, :boolean
    field :geo, :json
    field :slug, :string
    field :zone_name, :string
    field :user, :user_type, resolve: assoc(:user)
  end

  object :user_status_type do
    field :id, :string
    field :title, :string
    field :description, :string
  end

  object :get_user_by_type do
    field :id, :integer
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
  end

  object :delete_user_type do
    field :message, :string
  end

  input_object :delete_user_input_type do
    field :delete_confirmation, non_null(:boolean)
  end

  input_object :user_address_input_type do
    field :user_id, :id
    field :address, non_null(:string)
    field :primary, non_null(:boolean)
    field :geo, non_null(:geo)
    field :slug, non_null(:string)
    field :zone_name, :string
  end

  input_object :user_address_update_type do
    field :id, non_null(:id)
    field :user_id, :id
    field :primary, :boolean
    field :address, non_null(:string)
    field :geo, non_null(:geo)
    field :slug, non_null(:string)
    field :zone_name, :string
  end

  input_object :user_address_get_type do
    field :user_id, non_null(:id)
  end

  input_object :get_user_by_input_type do
    field :email, non_null(:string)
  end

  input_object :user_address_delete_type do
    field :address_id, non_null(:id)
  end

  input_object :user_straight_input_type do
    field :email, non_null(:string)
    #    field :password, :string
    field :mobile, :string
    field :friend_referral_code, :string
    #    field :status_id, :string
    #    field :birth_at, :string
    field :address, :string
    #    field :gender, :string
    #    field :language_id, :integer
    field :country_id, :integer
    #    field :has_business, :boolean
    #    field :rating, :float
    #    field :rating_count, :integer
    #    field :platform_terms_and_condition_id, :integer
    field :profile, non_null(:profile_input_type)
    #    field :profile_public, :boolean
    #    field :availability, :bsp_availability
    field :install, :user_installs_input_type
    #    field :user_address, list_of(:user_address_input_type)
    #    field :business, :business_input_type
    #    field :branch, :branch_input_type
  end

  input_object :user_straight_update_type do
    field :id, :id
    field :referral_code, :string
    field :mobile, :string
    field :status_id, :string
    field :birth_at, :string
    field :address, :string
    field :gender, :string
    field :language_id, :integer
    field :country_id, :integer
    #    field :has_business, :boolean
    field :platform_terms_and_condition_id, :integer
    field :rating, :float
    field :rating_count, :integer
    field :profile, :profile_input_type
    field :profile_public, :boolean
    #    field :availability, :bsp_availability
    field :install, :user_installs_update_type
    #    field :business, :business_input_type
    #    field :branch, :branch_input_type
  end

  input_object :user_input_type do
    field :email, :string
    field :password, :string
    field :mobile, :string
    field :friend_referral_code, :string
    field :status_id, :string
    field :birth_at, :string
    field :address, :string
    field :gender, :string
    field :language_id, :integer
    field :country_id, :integer
    #    field :has_business, :boolean
    field :rating, :float
    field :rating_count, :integer
    field :platform_terms_and_condition_id, :integer
    field :profile, :profile_input_type
    field :profile_public, :boolean
    #    field :availability, :bsp_availability
    field :install, :user_installs_input_type
    field :user_address, list_of(:user_address_input_type)
    #    field :business, :business_input_type
    #    field :branch, :branch_input_type
  end

  input_object :register_confirmation_input_type do
    field :email, non_null(:string)
    field :token, non_null(:integer)
  end

  input_object :user_update_type do
    field :id, :id
    field :mobile, :string
    field :status_id, :string
    field :birth_at, :string
    field :address, :string
    field :gender, :string
    field :language_id, :integer
    field :country_id, :integer
    #    field :has_business, :boolean
    field :platform_terms_and_condition_id, :integer
    field :rating, :float
    field :rating_count, :integer
    field :profile, :profile_input_type
    field :profile_public, :boolean
    #    field :availability, :bsp_availability
    field :install, :user_installs_update_type
    field :refresh_token, :string
    #    field :business, :business_input_type
    #    field :branch, :branch_input_type
  end

  #  input_object :bsp_availability do
  #    field :monday, :bsp_shift
  #    field :tuesday, :bsp_shift
  #    field :wednesday, :bsp_shift
  #    field :thursday, :bsp_shift
  #    field :friday, :bsp_shift
  #    field :saturday, :bsp_shift
  #    field :sunday, :bsp_shift
  #  end
  #  input_object :bsp_shift do
  #    field :a, list_of(:to_from)
  #    field :b, list_of(:to_from)
  #    field :c, list_of(:to_from)
  #    field :d, list_of(:to_from)
  #  end

  input_object :user_status_input_type do
    field :id, non_null(:id)
    field :title, :string
    field :description, :string
  end

  input_object :user_status_update_type do
    field :id, non_null(:id)
    field :title, :string
    field :description, :string
  end

  input_object :user_status_get_type do
    field :id, non_null(:id)
  end
end
