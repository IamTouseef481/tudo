defmodule CoreWeb.GraphQL.Types.UpsertSeedsType do
  use CoreWeb.GraphQL, :type

  object :upsert_seeds_type do
    field :message, :string
  end

  input_object :upsert_seeds_input_type do
    field :upsert_seeds, list_of(:string)
  end
end
