defmodule CoreWeb.GraphQL.Resolvers.RegionResolver do
  @moduledoc false
  alias Core.Regions
  alias CoreWeb.Utils.FileHandler

  def list_countries(_, _, _) do
    countries = Regions.list_countries()
    {:ok, countries.entries}
  end

  def list_cities(_, _, _) do
    {:ok, Regions.list_cities()}
  end

  def list_states(_, _, _) do
    {:ok, Regions.list_states()}
  end

  def list_continents(_, _, _) do
    {:ok, Regions.list_continents()}
  end

  def list_languages(_, _, _) do
    {:ok, Regions.list_languages()}
  end

  def get_language_by_id(_, %{input: %{id: id}}, _) do
    case Regions.get_languages!(id) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  #  def translations(_, %{input: %{language_code: lang}}, _) do
  #    lang = String.downcase(lang)
  #    screen_slugs = FileHandler.read_translations_slug_file()
  #    {:ok, screen_slugs}
  #  end

  def translations(_, _, _) do
    {:ok, FileHandler.read_translations_slug_file()}
  end
end
