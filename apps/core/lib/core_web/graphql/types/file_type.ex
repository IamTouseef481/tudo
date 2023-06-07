defmodule CoreWeb.GraphQL.Types.FileType do
  @moduledoc false
  use CoreWeb.GraphQL, :type

  input_object :file do
    field :thumb, :string
    field :original, :string
  end
end
