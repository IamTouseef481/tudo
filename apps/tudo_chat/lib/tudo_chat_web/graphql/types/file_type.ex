defmodule TudoChatWeb.GraphQL.Types.FileType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type

  input_object :file do
    field :thumb, :string
    field :original, :string
  end
end
