defmodule CoreWeb.GraphQL.Types.ProfileType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :profile_type do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:gender, :integer)
    field(:dob, :integer)
    field(:country_id, :id)
    field(:profile_image, :string)
  end

  input_object :profile_input_type do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:gender, :string)
    field(:dob, :string)
    field(:country_id, :id)
    #    field(:profile_image, :string)
    field(:profile_image, :upload)
    field(:rest_profile_image, :file)
  end
end
