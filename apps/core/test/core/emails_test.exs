defmodule Core.EmailsTest do
  use Core.DataCase

  alias Core.Emails

  describe "email_templates" do
    alias Core.Schemas.EmailTemplates

    @valid_attrs %{
      cc: [],
      html_body: "some html_body",
      is_active: true,
      slug: "some slug",
      subject: "some subject",
      text_body: "some text_body"
    }
    @update_attrs %{
      cc: [],
      html_body: "some updated html_body",
      is_active: false,
      slug: "some updated slug",
      subject: "some updated subject",
      text_body: "some updated text_body"
    }
    @invalid_attrs %{
      cc: nil,
      html_body: nil,
      is_active: nil,
      slug: nil,
      subject: nil,
      text_body: nil
    }

    def email_templates_fixture(attrs \\ %{}) do
      {:ok, email_templates} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Emails.create_email_templates()

      email_templates
    end

    test "list_email_templates/0 returns all email_templates" do
      email_templates = email_templates_fixture()
      assert Emails.list_email_templates() == [email_templates]
    end

    test "get_email_templates!/1 returns the email_templates with given id" do
      email_templates = email_templates_fixture()
      assert Emails.get_email_templates!(email_templates.id) == email_templates
    end

    test "create_email_templates/1 with valid data creates a email_templates" do
      assert {:ok, %EmailTemplates{} = email_templates} =
               Emails.create_email_templates(@valid_attrs)

      assert email_templates.cc == []
      assert email_templates.html_body == "some html_body"
      assert email_templates.is_active == true
      assert email_templates.slug == "some slug"
      assert email_templates.subject == "some subject"
      assert email_templates.text_body == "some text_body"
    end

    test "create_email_templates/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_email_templates(@invalid_attrs)
    end

    test "update_email_templates/2 with valid data updates the email_templates" do
      email_templates = email_templates_fixture()

      assert {:ok, %EmailTemplates{} = email_templates} =
               Emails.update_email_templates(email_templates, @update_attrs)

      assert email_templates.cc == []
      assert email_templates.html_body == "some updated html_body"
      assert email_templates.is_active == false
      assert email_templates.slug == "some updated slug"
      assert email_templates.subject == "some updated subject"
      assert email_templates.text_body == "some updated text_body"
    end

    test "update_email_templates/2 with invalid data returns error changeset" do
      email_templates = email_templates_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Emails.update_email_templates(email_templates, @invalid_attrs)

      assert email_templates == Emails.get_email_templates!(email_templates.id)
    end

    test "delete_email_templates/1 deletes the email_templates" do
      email_templates = email_templates_fixture()
      assert {:ok, %EmailTemplates{}} = Emails.delete_email_templates(email_templates)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_email_templates!(email_templates.id) end
    end

    test "change_email_templates/1 returns a email_templates changeset" do
      email_templates = email_templates_fixture()
      assert %Ecto.Changeset{} = Emails.change_email_templates(email_templates)
    end
  end

  describe "token" do
    alias Core.Emails.Random_tokens

    @valid_attrs %{
      app: "some app",
      day_count: 42,
      expired_at: "2010-04-17T14:00:00Z",
      history: [],
      hour_count: 42,
      login: "some login",
      min_count: 42,
      purpose: "some purpose"
    }
    @update_attrs %{
      app: "some updated app",
      day_count: 43,
      expired_at: "2011-05-18T15:01:01Z",
      history: [],
      hour_count: 43,
      login: "some updated login",
      min_count: 43,
      purpose: "some updated purpose"
    }
    @invalid_attrs %{
      app: nil,
      day_count: nil,
      expired_at: nil,
      history: nil,
      hour_count: nil,
      login: nil,
      min_count: nil,
      purpose: nil
    }

    def random_tokens_fixture(attrs \\ %{}) do
      {:ok, random_tokens} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Emails.create_random_tokens()

      random_tokens
    end

    test "list_token/0 returns all token" do
      random_tokens = random_tokens_fixture()
      assert Emails.list_token() == [random_tokens]
    end

    test "get_random_tokens!/1 returns the random_tokens with given id" do
      random_tokens = random_tokens_fixture()
      assert Emails.get_random_tokens!(random_tokens.id) == random_tokens
    end

    test "create_random_tokens/1 with valid data creates a random_tokens" do
      assert {:ok, %Random_tokens{} = random_tokens} = Emails.create_random_tokens(@valid_attrs)
      assert random_tokens.app == "some app"
      assert random_tokens.day_count == 42
      assert random_tokens.expired_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert random_tokens.history == []
      assert random_tokens.hour_count == 42
      assert random_tokens.login == "some login"
      assert random_tokens.min_count == 42
      assert random_tokens.purpose == "some purpose"
    end

    test "create_random_tokens/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_random_tokens(@invalid_attrs)
    end

    test "update_random_tokens/2 with valid data updates the random_tokens" do
      random_tokens = random_tokens_fixture()

      assert {:ok, %Random_tokens{} = random_tokens} =
               Emails.update_random_tokens(random_tokens, @update_attrs)

      assert random_tokens.app == "some updated app"
      assert random_tokens.day_count == 43
      assert random_tokens.expired_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert random_tokens.history == []
      assert random_tokens.hour_count == 43
      assert random_tokens.login == "some updated login"
      assert random_tokens.min_count == 43
      assert random_tokens.purpose == "some updated purpose"
    end

    test "update_random_tokens/2 with invalid data returns error changeset" do
      random_tokens = random_tokens_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Emails.update_random_tokens(random_tokens, @invalid_attrs)

      assert random_tokens == Emails.get_random_tokens!(random_tokens.id)
    end

    test "delete_random_tokens/1 deletes the random_tokens" do
      random_tokens = random_tokens_fixture()
      assert {:ok, %Random_tokens{}} = Emails.delete_random_tokens(random_tokens)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_random_tokens!(random_tokens.id) end
    end

    test "change_random_tokens/1 returns a random_tokens changeset" do
      random_tokens = random_tokens_fixture()
      assert %Ecto.Changeset{} = Emails.change_random_tokens(random_tokens)
    end
  end

  describe "random_tokens" do
    alias Core.Schemas.RandomTokens

    @valid_attrs %{
      app: "some app",
      day_count: 42,
      expired_at: "2010-04-17T14:00:00Z",
      history: [],
      hour_count: 42,
      login: "some login",
      min_count: 42,
      purpose: "some purpose",
      token: "some token"
    }
    @update_attrs %{
      app: "some updated app",
      day_count: 43,
      expired_at: "2011-05-18T15:01:01Z",
      history: [],
      hour_count: 43,
      login: "some updated login",
      min_count: 43,
      purpose: "some updated purpose",
      token: "some updated token"
    }
    @invalid_attrs %{
      app: nil,
      day_count: nil,
      expired_at: nil,
      history: nil,
      hour_count: nil,
      login: nil,
      min_count: nil,
      purpose: nil,
      token: nil
    }

    def random_tokens_fixture(attrs \\ %{}) do
      {:ok, random_tokens} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Emails.create_random_tokens()

      random_tokens
    end

    test "list_random_tokens/0 returns all random_tokens" do
      random_tokens = random_tokens_fixture()
      assert Emails.list_random_tokens() == [random_tokens]
    end

    test "get_random_tokens!/1 returns the random_tokens with given id" do
      random_tokens = random_tokens_fixture()
      assert Emails.get_random_tokens!(random_tokens.id) == random_tokens
    end

    test "create_random_tokens/1 with valid data creates a random_tokens" do
      assert {:ok, %RandomTokens{} = random_tokens} = Emails.create_random_tokens(@valid_attrs)
      assert random_tokens.app == "some app"
      assert random_tokens.day_count == 42
      assert random_tokens.expired_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert random_tokens.history == []
      assert random_tokens.hour_count == 42
      assert random_tokens.login == "some login"
      assert random_tokens.min_count == 42
      assert random_tokens.purpose == "some purpose"
      assert random_tokens.token == "some token"
    end

    test "create_random_tokens/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_random_tokens(@invalid_attrs)
    end

    test "update_random_tokens/2 with valid data updates the random_tokens" do
      random_tokens = random_tokens_fixture()

      assert {:ok, %RandomTokens{} = random_tokens} =
               Emails.update_random_tokens(random_tokens, @update_attrs)

      assert random_tokens.app == "some updated app"
      assert random_tokens.day_count == 43
      assert random_tokens.expired_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert random_tokens.history == []
      assert random_tokens.hour_count == 43
      assert random_tokens.login == "some updated login"
      assert random_tokens.min_count == 43
      assert random_tokens.purpose == "some updated purpose"
      assert random_tokens.token == "some updated token"
    end

    test "update_random_tokens/2 with invalid data returns error changeset" do
      random_tokens = random_tokens_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Emails.update_random_tokens(random_tokens, @invalid_attrs)

      assert random_tokens == Emails.get_random_tokens!(random_tokens.id)
    end

    test "delete_random_tokens/1 deletes the random_tokens" do
      random_tokens = random_tokens_fixture()
      assert {:ok, %RandomTokens{}} = Emails.delete_random_tokens(random_tokens)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_random_tokens!(random_tokens.id) end
    end

    test "change_random_tokens/1 returns a random_tokens changeset" do
      random_tokens = random_tokens_fixture()
      assert %Ecto.Changeset{} = Emails.change_random_tokens(random_tokens)
    end
  end

  describe "email_categories" do
    alias Core.Schemas.EmailCategory

    @valid_attrs %{description: "some description", id: "some id"}
    @update_attrs %{description: "some updated description", id: "some updated id"}
    @invalid_attrs %{description: nil, id: nil}

    def email_category_fixture(attrs \\ %{}) do
      {:ok, email_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Emails.create_email_category()

      email_category
    end

    test "list_email_categories/0 returns all email_categories" do
      email_category = email_category_fixture()
      assert Emails.list_email_categories() == [email_category]
    end

    test "get_email_category!/1 returns the email_category with given id" do
      email_category = email_category_fixture()
      assert Emails.get_email_category!(email_category.id) == email_category
    end

    test "create_email_category/1 with valid data creates a email_category" do
      assert {:ok, %EmailCategory{} = email_category} = Emails.create_email_category(@valid_attrs)
      assert email_category.description == "some description"
      assert email_category.id == "some id"
    end

    test "create_email_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_email_category(@invalid_attrs)
    end

    test "update_email_category/2 with valid data updates the email_category" do
      email_category = email_category_fixture()

      assert {:ok, %EmailCategory{} = email_category} =
               Emails.update_email_category(email_category, @update_attrs)

      assert email_category.description == "some updated description"
      assert email_category.id == "some updated id"
    end

    test "update_email_category/2 with invalid data returns error changeset" do
      email_category = email_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Emails.update_email_category(email_category, @invalid_attrs)

      assert email_category == Emails.get_email_category!(email_category.id)
    end

    test "delete_email_category/1 deletes the email_category" do
      email_category = email_category_fixture()
      assert {:ok, %EmailCategory{}} = Emails.delete_email_category(email_category)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_email_category!(email_category.id) end
    end

    test "change_email_category/1 returns a email_category changeset" do
      email_category = email_category_fixture()
      assert %Ecto.Changeset{} = Emails.change_email_category(email_category)
    end
  end

  describe "email_settings" do
    alias Core.Schemas.EmailSetting

    @valid_attrs %{is_active: true, slug: "some slug"}
    @update_attrs %{is_active: false, slug: "some updated slug"}
    @invalid_attrs %{is_active: nil, slug: nil}

    def email_setting_fixture(attrs \\ %{}) do
      {:ok, email_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Emails.create_email_setting()

      email_setting
    end

    test "list_email_settings/0 returns all email_settings" do
      email_setting = email_setting_fixture()
      assert Emails.list_email_settings() == [email_setting]
    end

    test "get_email_setting!/1 returns the email_setting with given id" do
      email_setting = email_setting_fixture()
      assert Emails.get_email_setting!(email_setting.id) == email_setting
    end

    test "create_email_setting/1 with valid data creates a email_setting" do
      assert {:ok, %EmailSetting{} = email_setting} = Emails.create_email_setting(@valid_attrs)
      assert email_setting.is_active == true
      assert email_setting.slug == "some slug"
    end

    test "create_email_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Emails.create_email_setting(@invalid_attrs)
    end

    test "update_email_setting/2 with valid data updates the email_setting" do
      email_setting = email_setting_fixture()

      assert {:ok, %EmailSetting{} = email_setting} =
               Emails.update_email_setting(email_setting, @update_attrs)

      assert email_setting.is_active == false
      assert email_setting.slug == "some updated slug"
    end

    test "update_email_setting/2 with invalid data returns error changeset" do
      email_setting = email_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Emails.update_email_setting(email_setting, @invalid_attrs)

      assert email_setting == Emails.get_email_setting!(email_setting.id)
    end

    test "delete_email_setting/1 deletes the email_setting" do
      email_setting = email_setting_fixture()
      assert {:ok, %EmailSetting{}} = Emails.delete_email_setting(email_setting)
      assert_raise Ecto.NoResultsError, fn -> Emails.get_email_setting!(email_setting.id) end
    end

    test "change_email_setting/1 returns a email_setting changeset" do
      email_setting = email_setting_fixture()
      assert %Ecto.Changeset{} = Emails.change_email_setting(email_setting)
    end
  end
end
