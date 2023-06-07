defmodule CoreWeb.GraphQL.Types.ErrorType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  object :dart_error_type do
    field :id, :id
    field :tag, :string
    field :level, :string
    field :message, :string
    field :error_time, :string
  end

  input_object :dart_error_input_type do
    field :tag, :string
    field :level, :string
    field :message, :string
  end

  input_object :dart_error_update_type do
    field :id, non_null(:id)
    field :tag, :string
    field :level, :string
    field :message, :string
  end

  input_object :dart_error_get_type do
    field :id, non_null(:id)
  end
end
