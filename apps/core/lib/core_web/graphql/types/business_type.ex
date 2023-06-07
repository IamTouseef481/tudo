defmodule CoreWeb.GraphQL.Types.BusinessType do
  @moduledoc false
  use CoreWeb.GraphQL, :type
  import Ecto.Query
  alias Core.Schemas.{BusinessType, TermsAndCondition}

  object :business_type do
    field :id, :id
    field :name, :string
    field :description, :string
    field :phone, :string
    field :agree_to_pay_for_verification, :boolean
    field :is_active, :boolean
    field :is_verified, :boolean
    field :settings, :business_settings_type
    field :rating, :float
    field :rating_count, :integer
    field :employees_count, :integer
    field :terms_and_conditions, list_of(:integer)
    field :profile_pictures, list_of(:json)
    field :user, :user_type, resolve: assoc(:user)
    #    field :business_type, :business_type_type, resolve: assoc(:business_type)
    field :branches, list_of(:branch_type), resolve: assoc(:branches)
    field :status, :user_status_type, resolve: assoc(:status)
    #    field :business_type, :business_type_type do
    #      resolve fn business_type, _, _ ->
    #        batch({__MODULE__, :business_type_by_id}, business_type.business_type_id, fn batch_results ->
    #          {:ok, Map.get(batch_results, business_type.business_type_id)}
    #        end)
    #      end
    #    end
    #    field :terms_and_conditions, :terms_and_conditions_type do
    #      resolve fn terms_and_conditions_type, _, _ ->
    #        batch({__MODULE__, :terms_and_conditions_by_id}, terms_and_conditions_type.terms_and_conditions_id, fn batch_results ->
    #          {:ok, Map.get(batch_results, terms_and_conditions_type.terms_and_conditions_id)}
    #        end)
    #      end
    #    end
  end

  object :business_settings_type do
    field :provides_on_demand, :boolean
    field :provides_walkin, :boolean
    field :provides_home_service, :boolean
  end

  input_object :business_settings_input_type do
    field :provides_on_demand, non_null(:boolean)
    field :provides_walkin, non_null(:boolean)
    field :provides_home_service, non_null(:boolean)
  end

  input_object :business_settings_update_type do
    field :provides_on_demand, :boolean
    field :provides_walkin, :boolean
    field :provides_home_service, :boolean
  end

  #  input_object :path do
  #    field :thumb, :string
  #    field :original, :string
  #  end

  input_object :max_allowed_discount_type do
    field :max_value, :float
    field :selected_value, :float
    field :is_percentage, :boolean
    field :allow, :boolean
  end

  input_object :business_straight_input_type do
    field :raw_business_id, :integer
    field :name, non_null(:string)
    field :phone, non_null(:string)
    field :branch, non_null(:branch_business_straight_input_type)
    field :user, non_null(:user_straight_input_type)
    field :profile_pictures, list_of(:upload)
    field :rest_profile_pictures, list_of(:file)
    field :employees_count, :integer
    field :terms_and_conditions, non_null(list_of(:integer))
  end

  #  input_object :business_straight_update_type do
  #    field :id, non_null(:integer)
  #    #    field :name, :string
  #    #    field :description, :string
  #    #    field :phone, :string
  #    #    field :business_type_id, :integer
  #    field :profile_pictures, list_of(:upload)
  #    field :rest_profile_pictures, list_of(:file)
  #    #    field :settings, :business_settings_update_type
  #    field :employees_count, :integer
  #    #    field :agree_to_pay_for_verification, :boolean
  #    #    field :terms_and_conditions, list_of(:integer)
  #  end

  input_object :business_input_type do
    field :user_id, :integer
    field :raw_business_id, :integer
    field :name, non_null(:string)
    field :description, :string
    field :phone, :string
    field :branch, :branch_business_input_type
    #    field :business_type_id, non_null(:integer)
    field :profile_pictures, list_of(:upload)
    field :rest_profile_pictures, list_of(:file)
    field :settings, non_null(:business_settings_input_type)
    field :employees_count, non_null(:integer)
    field :agree_to_pay_for_verification, non_null(:boolean)
    field :terms_and_conditions, list_of(:integer)
    #    field :max_allowed_discount, :max_allowed_discount_type
    #    field :max_allowed_tax, :max_allowed_discount_type
  end

  input_object :business_update_type do
    field :id, non_null(:integer)
    field :name, :string
    field :description, :string
    field :phone, :string
    field :business_type_id, :integer
    field :profile_pictures, list_of(:upload)
    field :rest_profile_pictures, list_of(:file)
    field :settings, :business_settings_update_type
    field :employees_count, :integer
    field :agree_to_pay_for_verification, :boolean
    field :terms_and_conditions, list_of(:integer)
  end

  input_object :business_delete_type do
    field :id, non_null(:integer)
  end

  input_object :business_activate_type do
    field :business_id, non_null(:integer)
    field :status_id, non_null(:string)
  end

  # DUPLICATE CODE SHOULD BE REMOVED
  def business_type_by_id(_, ids) do
    BusinessType
    |> where([m], m.id in ^ids)
    |> Core.Repo.all()
    |> Map.new(&{&1.id, &1})
  end

  def terms_and_conditions_by_id(_, ids) do
    TermsAndCondition
    |> where([m], m.id in ^ids)
    |> Core.Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
