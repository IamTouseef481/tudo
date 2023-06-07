defmodule CoreWeb.GraphQL.Types.ReferralType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :user_referral_type do
    field :payment_method_setup, :boolean
    field :is_accept, :boolean
    field :email, :string
    field :user_from, :user_type, resolve: assoc(:referred_to)
  end

  input_object :invite_user_input_type do
    field :email, non_null(:string)
    field :friend_name, :string
  end
end
