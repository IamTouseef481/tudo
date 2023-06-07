defmodule Core.TranslationsTest do
  use Core.DataCase

  alias Core.Translations

  describe "screens" do
    alias Core.Schemas.Screen

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def screen_fixture(attrs \\ %{}) do
      {:ok, screen} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Translations.create_screen()

      screen
    end

    test "list_screens/0 returns all screens" do
      screen = screen_fixture()
      assert Translations.list_screens() == [screen]
    end

    test "get_screen!/1 returns the screen with given id" do
      screen = screen_fixture()
      assert Translations.get_screen!(screen.id) == screen
    end

    test "create_screen/1 with valid data creates a screen" do
      assert {:ok, %Screen{} = screen} = Translations.create_screen(@valid_attrs)
      assert screen.description == "some description"
      assert screen.id == "some id"
    end

    test "create_screen/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_screen(@invalid_attrs)
    end

    test "update_screen/2 with valid data updates the screen" do
      screen = screen_fixture()
      assert {:ok, %Screen{} = screen} = Translations.update_screen(screen, @update_attrs)
      assert screen.description == "some updated description"
      assert screen.id == "some updated id"
    end

    test "update_screen/2 with invalid data returns error changeset" do
      screen = screen_fixture()
      assert {:error, %Ecto.Changeset{}} = Translations.update_screen(screen, @invalid_attrs)
      assert screen == Translations.get_screen!(screen.id)
    end

    test "delete_screen/1 deletes the screen" do
      screen = screen_fixture()
      assert {:ok, %Screen{}} = Translations.delete_screen(screen)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_screen!(screen.id) end
    end

    test "change_screen/1 returns a screen changeset" do
      screen = screen_fixture()
      assert %Ecto.Changeset{} = Translations.change_screen(screen)
    end
  end

  describe "translations" do
    alias Core.Schemas.Translation

    @valid_attrs %{
      field_id: 42,
      language: "some language",
      slug: "some slug",
      translation: "some translation"
    }
    @update_attrs %{
      field_id: 43,
      language: "some updated language",
      slug: "some updated slug",
      translation: "some updated translation"
    }
    @invalid_attrs %{field_id: nil, language: nil, slug: nil, translation: nil}

    def translation_fixture(attrs \\ %{}) do
      {:ok, translation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Translations.create_translation()

      translation
    end

    test "list_translations/0 returns all translations" do
      translation = translation_fixture()
      assert Translations.list_translations() == [translation]
    end

    test "get_translation!/1 returns the translation with given id" do
      translation = translation_fixture()
      assert Translations.get_translation!(translation.id) == translation
    end

    test "create_translation/1 with valid data creates a translation" do
      assert {:ok, %Translation{} = translation} = Translations.create_translation(@valid_attrs)
      assert translation.field_id == 42
      assert translation.language == "some language"
      assert translation.slug == "some slug"
      assert translation.translation == "some translation"
    end

    test "create_translation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Translations.create_translation(@invalid_attrs)
    end

    test "update_translation/2 with valid data updates the translation" do
      translation = translation_fixture()

      assert {:ok, %Translation{} = translation} =
               Translations.update_translation(translation, @update_attrs)

      assert translation.field_id == 43
      assert translation.language == "some updated language"
      assert translation.slug == "some updated slug"
      assert translation.translation == "some updated translation"
    end

    test "update_translation/2 with invalid data returns error changeset" do
      translation = translation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation(translation, @invalid_attrs)

      assert translation == Translations.get_translation!(translation.id)
    end

    test "delete_translation/1 deletes the translation" do
      translation = translation_fixture()
      assert {:ok, %Translation{}} = Translations.delete_translation(translation)
      assert_raise Ecto.NoResultsError, fn -> Translations.get_translation!(translation.id) end
    end

    test "change_translation/1 returns a translation changeset" do
      translation = translation_fixture()
      assert %Ecto.Changeset{} = Translations.change_translation(translation)
    end
  end
end
