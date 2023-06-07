defmodule CoreWeb.GraphQL.Resolvers.UpsertSeedsResolver do
  @moduledoc false
  use CoreWeb.Helpers.UpsertSeedsHelper

  def upsert_seeds(_, %{input: %{upsert_seeds: table_names}}, %{
        context: %{current_user: _current_user}
      }) do
    Enum.each(table_names, fn table_name ->
      import_from_csv(table_name, &map_to_table(&1, &2, &3))
    end)

    {:ok, %{message: "Insertion Started..."}}
  end
end
