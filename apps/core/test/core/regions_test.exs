defmodule Core.RegionsTest do
  use Core.DataCase

  alias Core.Regions

  describe "continents" do
    alias Core.Schemas.Continents

    @valid_attrs %{code: "some code", name: "some name"}
    @update_attrs %{code: "some updated code", name: "some updated name"}
    @invalid_attrs %{code: nil, name: nil}

    def continents_fixture(attrs \\ %{}) do
      {:ok, continents} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_continents()

      continents
    end

    test "list_continents/0 returns all continents" do
      continents = continents_fixture()
      assert Regions.list_continents() == [continents]
    end

    test "get_continents!/1 returns the continents with given id" do
      continents = continents_fixture()
      assert Regions.get_continents!(continents.id) == continents
    end

    test "create_continents/1 with valid data creates a continents" do
      assert {:ok, %Continents{} = continents} = Regions.create_continents(@valid_attrs)
      assert continents.code == "some code"
      assert continents.name == "some name"
    end

    test "create_continents/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_continents(@invalid_attrs)
    end

    test "update_continents/2 with valid data updates the continents" do
      continents = continents_fixture()

      assert {:ok, %Continents{} = continents} =
               Regions.update_continents(continents, @update_attrs)

      assert continents.code == "some updated code"
      assert continents.name == "some updated name"
    end

    test "update_continents/2 with invalid data returns error changeset" do
      continents = continents_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_continents(continents, @invalid_attrs)
      assert continents == Regions.get_continents!(continents.id)
    end

    test "delete_continents/1 deletes the continents" do
      continents = continents_fixture()
      assert {:ok, %Continents{}} = Regions.delete_continents(continents)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_continents!(continents.id) end
    end

    test "change_continents/1 returns a continents changeset" do
      continents = continents_fixture()
      assert %Ecto.Changeset{} = Regions.change_continents(continents)
    end
  end

  describe "code" do
    alias Core.Schemas.Languages

    @valid_attrs %{is_active: true, name: "some name"}
    @update_attrs %{is_active: false, name: "some updated name"}
    @invalid_attrs %{is_active: nil, name: nil}

    def languages_fixture(attrs \\ %{}) do
      {:ok, languages} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_languages()

      languages
    end

    test "list_code/0 returns all code" do
      languages = languages_fixture()
      assert Regions.list_code() == [languages]
    end

    test "get_languages!/1 returns the languages with given id" do
      languages = languages_fixture()
      assert Regions.get_languages!(languages.id) == languages
    end

    test "create_languages/1 with valid data creates a languages" do
      assert {:ok, %Languages{} = languages} = Regions.create_languages(@valid_attrs)
      assert languages.is_active == true
      assert languages.name == "some name"
    end

    test "create_languages/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_languages(@invalid_attrs)
    end

    test "update_languages/2 with valid data updates the languages" do
      languages = languages_fixture()
      assert {:ok, %Languages{} = languages} = Regions.update_languages(languages, @update_attrs)
      assert languages.is_active == false
      assert languages.name == "some updated name"
    end

    test "update_languages/2 with invalid data returns error changeset" do
      languages = languages_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_languages(languages, @invalid_attrs)
      assert languages == Regions.get_languages!(languages.id)
    end

    test "delete_languages/1 deletes the languages" do
      languages = languages_fixture()
      assert {:ok, %Languages{}} = Regions.delete_languages(languages)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_languages!(languages.id) end
    end

    test "change_languages/1 returns a languages changeset" do
      languages = languages_fixture()
      assert %Ecto.Changeset{} = Regions.change_languages(languages)
    end
  end

  describe "countries" do
    alias Core.Schemas.Countries

    @valid_attrs %{
      capital: "some capital",
      code: "some code",
      currency_code: "some currency_code",
      currency_symbol: "some currency_symbol",
      isd_code: "some isd_code",
      name: "some name",
      nmc_code: "some nmc_code",
      official_name: "some official_name"
    }
    @update_attrs %{
      capital: "some updated capital",
      code: "some updated code",
      currency_code: "some updated currency_code",
      currency_symbol: "some updated currency_symbol",
      isd_code: "some updated isd_code",
      name: "some updated name",
      nmc_code: "some updated nmc_code",
      official_name: "some updated official_name"
    }
    @invalid_attrs %{
      capital: nil,
      code: nil,
      currency_code: nil,
      currency_symbol: nil,
      isd_code: nil,
      name: nil,
      nmc_code: nil,
      official_name: nil
    }

    def countries_fixture(attrs \\ %{}) do
      {:ok, countries} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_countries()

      countries
    end

    test "list_countries/0 returns all countries" do
      countries = countries_fixture()
      assert Regions.list_countries() == [countries]
    end

    test "get_countries!/1 returns the countries with given id" do
      countries = countries_fixture()
      assert Regions.get_countries!(countries.id) == countries
    end

    test "create_countries/1 with valid data creates a countries" do
      assert {:ok, %Countries{} = countries} = Regions.create_countries(@valid_attrs)
      assert countries.capital == "some capital"
      assert countries.code == "some code"
      assert countries.currency_code == "some currency_code"
      assert countries.currency_symbol == "some currency_symbol"
      assert countries.isd_code == "some isd_code"
      assert countries.name == "some name"
      assert countries.nmc_code == "some nmc_code"
      assert countries.official_name == "some official_name"
    end

    test "create_countries/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_countries(@invalid_attrs)
    end

    test "update_countries/2 with valid data updates the countries" do
      countries = countries_fixture()
      assert {:ok, %Countries{} = countries} = Regions.update_countries(countries, @update_attrs)
      assert countries.capital == "some updated capital"
      assert countries.code == "some updated code"
      assert countries.currency_code == "some updated currency_code"
      assert countries.currency_symbol == "some updated currency_symbol"
      assert countries.isd_code == "some updated isd_code"
      assert countries.name == "some updated name"
      assert countries.nmc_code == "some updated nmc_code"
      assert countries.official_name == "some updated official_name"
    end

    test "update_countries/2 with invalid data returns error changeset" do
      countries = countries_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_countries(countries, @invalid_attrs)
      assert countries == Regions.get_countries!(countries.id)
    end

    test "delete_countries/1 deletes the countries" do
      countries = countries_fixture()
      assert {:ok, %Countries{}} = Regions.delete_countries(countries)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_countries!(countries.id) end
    end

    test "change_countries/1 returns a countries changeset" do
      countries = countries_fixture()
      assert %Ecto.Changeset{} = Regions.change_countries(countries)
    end
  end

  describe "states" do
    alias Core.Schemas.States

    @valid_attrs %{
      capital: "some capital",
      fips_code: "some fips_code",
      name: "some name",
      short_code: "some short_code"
    }
    @update_attrs %{
      capital: "some updated capital",
      fips_code: "some updated fips_code",
      name: "some updated name",
      short_code: "some updated short_code"
    }
    @invalid_attrs %{capital: nil, fips_code: nil, name: nil, short_code: nil}

    def states_fixture(attrs \\ %{}) do
      {:ok, states} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_states()

      states
    end

    test "list_states/0 returns all states" do
      states = states_fixture()
      assert Regions.list_states() == [states]
    end

    test "get_states!/1 returns the states with given id" do
      states = states_fixture()
      assert Regions.get_states!(states.id) == states
    end

    test "create_states/1 with valid data creates a states" do
      assert {:ok, %States{} = states} = Regions.create_states(@valid_attrs)
      assert states.capital == "some capital"
      assert states.fips_code == "some fips_code"
      assert states.name == "some name"
      assert states.short_code == "some short_code"
    end

    test "create_states/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_states(@invalid_attrs)
    end

    test "update_states/2 with valid data updates the states" do
      states = states_fixture()
      assert {:ok, %States{} = states} = Regions.update_states(states, @update_attrs)
      assert states.capital == "some updated capital"
      assert states.fips_code == "some updated fips_code"
      assert states.name == "some updated name"
      assert states.short_code == "some updated short_code"
    end

    test "update_states/2 with invalid data returns error changeset" do
      states = states_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_states(states, @invalid_attrs)
      assert states == Regions.get_states!(states.id)
    end

    test "delete_states/1 deletes the states" do
      states = states_fixture()
      assert {:ok, %States{}} = Regions.delete_states(states)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_states!(states.id) end
    end

    test "change_states/1 returns a states changeset" do
      states = states_fixture()
      assert %Ecto.Changeset{} = Regions.change_states(states)
    end
  end

  describe "cities" do
    alias Core.Schemas.Cities

    @valid_attrs %{
      details: %{},
      name: "some name",
      search_vector: "some search_vector",
      short_code: "some short_code",
      zip: "some zip"
    }
    @update_attrs %{
      details: %{},
      name: "some updated name",
      search_vector: "some updated search_vector",
      short_code: "some updated short_code",
      zip: "some updated zip"
    }
    @invalid_attrs %{details: nil, name: nil, search_vector: nil, short_code: nil, zip: nil}

    def cities_fixture(attrs \\ %{}) do
      {:ok, cities} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_cities()

      cities
    end

    test "list_cities/0 returns all cities" do
      cities = cities_fixture()
      assert Regions.list_cities() == [cities]
    end

    test "get_cities!/1 returns the cities with given id" do
      cities = cities_fixture()
      assert Regions.get_cities!(cities.id) == cities
    end

    test "create_cities/1 with valid data creates a cities" do
      assert {:ok, %Cities{} = cities} = Regions.create_cities(@valid_attrs)
      assert cities.details == %{}
      assert cities.name == "some name"
      assert cities.search_vector == "some search_vector"
      assert cities.short_code == "some short_code"
      assert cities.zip == "some zip"
    end

    test "create_cities/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_cities(@invalid_attrs)
    end

    test "update_cities/2 with valid data updates the cities" do
      cities = cities_fixture()
      assert {:ok, %Cities{} = cities} = Regions.update_cities(cities, @update_attrs)
      assert cities.details == %{}
      assert cities.name == "some updated name"
      assert cities.search_vector == "some updated search_vector"
      assert cities.short_code == "some updated short_code"
      assert cities.zip == "some updated zip"
    end

    test "update_cities/2 with invalid data returns error changeset" do
      cities = cities_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_cities(cities, @invalid_attrs)
      assert cities == Regions.get_cities!(cities.id)
    end

    test "delete_cities/1 deletes the cities" do
      cities = cities_fixture()
      assert {:ok, %Cities{}} = Regions.delete_cities(cities)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_cities!(cities.id) end
    end

    test "change_cities/1 returns a cities changeset" do
      cities = cities_fixture()
      assert %Ecto.Changeset{} = Regions.change_cities(cities)
    end
  end

  describe "languages" do
    alias Core.Schemas.Languages

    @valid_attrs %{code: "some code", is_active: true, name: "some name"}
    @update_attrs %{code: "some updated code", is_active: false, name: "some updated name"}
    @invalid_attrs %{code: nil, is_active: nil, name: nil}

    def languages_fixture(attrs \\ %{}) do
      {:ok, languages} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_languages()

      languages
    end

    test "list_languages/0 returns all languages" do
      languages = languages_fixture()
      assert Regions.list_languages() == [languages]
    end

    test "get_languages!/1 returns the languages with given id" do
      languages = languages_fixture()
      assert Regions.get_languages!(languages.id) == languages
    end

    test "create_languages/1 with valid data creates a languages" do
      assert {:ok, %Languages{} = languages} = Regions.create_languages(@valid_attrs)
      assert languages.code == "some code"
      assert languages.is_active == true
      assert languages.name == "some name"
    end

    test "create_languages/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_languages(@invalid_attrs)
    end

    test "update_languages/2 with valid data updates the languages" do
      languages = languages_fixture()
      assert {:ok, %Languages{} = languages} = Regions.update_languages(languages, @update_attrs)
      assert languages.code == "some updated code"
      assert languages.is_active == false
      assert languages.name == "some updated name"
    end

    test "update_languages/2 with invalid data returns error changeset" do
      languages = languages_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_languages(languages, @invalid_attrs)
      assert languages == Regions.get_languages!(languages.id)
    end

    test "delete_languages/1 deletes the languages" do
      languages = languages_fixture()
      assert {:ok, %Languages{}} = Regions.delete_languages(languages)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_languages!(languages.id) end
    end

    test "change_languages/1 returns a languages changeset" do
      languages = languages_fixture()
      assert %Ecto.Changeset{} = Regions.change_languages(languages)
    end
  end

  describe "units" do
    alias Core.Schemas.Unit

    @valid_attrs %{description: "some description", name: "some name", slug: "some slug"}
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      slug: "some updated slug"
    }
    @invalid_attrs %{description: nil, name: nil, slug: nil}

    def unit_fixture(attrs \\ %{}) do
      {:ok, unit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Regions.create_unit()

      unit
    end

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Regions.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Regions.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      assert {:ok, %Unit{} = unit} = Regions.create_unit(@valid_attrs)
      assert unit.description == "some description"
      assert unit.name == "some name"
      assert unit.slug == "some slug"
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Regions.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{} = unit} = Regions.update_unit(unit, @update_attrs)
      assert unit.description == "some updated description"
      assert unit.name == "some updated name"
      assert unit.slug == "some updated slug"
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Regions.update_unit(unit, @invalid_attrs)
      assert unit == Regions.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Regions.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Regions.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Regions.change_unit(unit)
    end
  end
end
