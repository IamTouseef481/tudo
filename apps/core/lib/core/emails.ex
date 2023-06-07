defmodule Core.Emails do
  @moduledoc """
  The Emails context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    EmailCategory,
    EmailSetting,
    EmailTemplates,
    RandomTokens,
    BspEmailTemplate,
    Application
  }

  @doc """
  Returns the list of email_templates.

  ## Examples

      iex> list_email_templates()
      [%EmailTemplates{}, ...]

  """
  def list_email_templates do
    Repo.all(EmailTemplates)
  end

  def list_application do
    Repo.all(Application)
  end

  def list_email_templates(slug) do
    EmailTemplates
    |> where([bt], bt.slug == ^slug)
    |> Repo.all()
  end

  def list_bsp_email_template(branch_id), do: Repo.get_by(BspEmailTemplate, branch_id: branch_id)

  def apply_filter(input) do
    query = BspEmailTemplate |> where([bet], bet.branch_id == ^input.branch_id)

    query =
      if Map.has_key?(input, :send_in_blue_email_template_id),
        do:
          query
          |> where(
            [bet],
            bet.send_in_blue_email_template_id == ^input.send_in_blue_email_template_id
          ),
        else: query

    query =
      if Map.has_key?(input, :action),
        do: query |> where([bet], bet.action == ^input.action),
        else: query

    query =
      if Map.has_key?(input, :send_in_blue_notification_template_id),
        do:
          query
          |> where(
            [bet],
            bet.send_in_blue_notification_template_id ==
              ^input.send_in_blue_notification_template_id
          ),
        else: query

    query =
      if Map.has_key?(input, :application_id),
        do:
          query
          |> where(
            [bet],
            bet.application_id ==
              ^input.application_id
          ),
        else: query

    Repo.all(query)
  end

  @doc """
  Gets a single email_templates.

  Raises `Ecto.NoResultsError` if the Email templates does not exist.

  ## Examples

      iex> get_email_templates!(123)
      %EmailTemplates{}

      iex> get_email_templates!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email_templates!(id), do: Repo.get(EmailTemplates, id)
  def get_bsp_email_template!(id), do: Repo.get(BspEmailTemplate, id)

  def get_bsp_email_template_by(action, application_id, branch_id) do
    BspEmailTemplate
    |> where([bet], bet.action == ^action)
    |> where([bet], bet.branch_id == ^branch_id)
    |> where([bet], bet.application_id == ^application_id)
    |> Repo.one()
  end

  def get_email_templates_by(action, template_id) do
    EmailTemplates
    |> where([et], et.slug == ^action)
    |> where(
      [et],
      et.send_in_blue_email_template_id == ^template_id or
        et.send_in_blue_notification_template_id == ^template_id
    )
    |> Repo.one()
  end

  def get_template_id_by(action, branch_id) do
    BspEmailTemplate
    |> where([et], et.action == ^action)
    |> where(
      [et],
      et.branch_id == ^branch_id
    )
    |> Repo.one()
  end

  def get_email_templates(slug) do
    query = from r in EmailTemplates, where: r.slug == ^slug, limit: 1
    Repo.one(query)
  end

  def get_by_apply_filter(input) do
    query = EmailTemplates |> where([et], et.slug == ^input.slug)

    query =
      if Map.has_key?(input, :send_in_blue_email_template_id),
        do:
          query
          |> where(
            [et],
            et.send_in_blue_email_template_id == ^input.send_in_blue_email_template_id
          ),
        else: query

    query =
      if Map.has_key?(input, :send_in_blue_notification_template_id),
        do:
          query
          |> where(
            [et],
            et.send_in_blue_notification_template_id ==
              ^input.send_in_blue_notification_template_id
          ),
        else: query

    Repo.one(query)
  end

  @doc """
  Creates a email_templates.

  ## Examples

      iex> create_email_templates(%{field: value})
      {:ok, %EmailTemplates{}}

      iex> create_email_templates(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email_templates(attrs \\ %{}) do
    %EmailTemplates{}
    |> EmailTemplates.changeset(attrs)
    |> Repo.insert()
  end

  def create_bsp_email_template(attrs \\ %{}) do
    %BspEmailTemplate{}
    |> BspEmailTemplate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email_templates.

  ## Examples

      iex> update_email_templates(email_templates, %{field: new_value})
      {:ok, %EmailTemplates{}}

      iex> update_email_templates(email_templates, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_email_templates(%EmailTemplates{} = email_templates, attrs) do
    email_templates
    |> EmailTemplates.update_changeset(attrs)
    |> Repo.update()
  end

  def update_bsp_email_template(%BspEmailTemplate{} = bsp_email_template, attrs) do
    bsp_email_template
    |> BspEmailTemplate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a EmailTemplates.

  ## Examples

      iex> delete_email_templates(email_templates)
      {:ok, %EmailTemplates{}}

      iex> delete_email_templates(email_templates)
      {:error, %Ecto.Changeset{}}

  """
  def delete_email_templates(%EmailTemplates{} = email_templates) do
    Repo.delete(email_templates)
  end

  def delete_bsp_email_template(%BspEmailTemplate{} = bsp_email_template) do
    Repo.delete(bsp_email_template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_templates changes.

  ## Examples

      iex> change_email_templates(email_templates)
      %Ecto.Changeset{source: %EmailTemplates{}}

  """
  def change_email_templates(%EmailTemplates{} = email_templates) do
    EmailTemplates.changeset(email_templates, %{})
  end

  @doc """
  Returns the list of random_tokens.

  ## Examples

      iex> list_random_tokens()
      [%RandomTokens{}, ...]

  """
  def list_random_tokens do
    Repo.all(RandomTokens)
  end

  @doc """
  Gets a single random_tokens.

  Raises `Ecto.NoResultsError` if the Random tokens does not exist.

  ## Examples

      iex> get_random_tokens!(123)
      %RandomTokens{}

      iex> get_random_tokens!(456)
      ** (Ecto.NoResultsError)

  """
  def get_random_token_by_id!(id), do: Repo.get!(RandomTokens, id)

  def get_random_token!(%{email: email, token: token, purpose: purpose}) do
    query =
      from r in RandomTokens,
        where: r.login == ^String.downcase(email) and r.token == ^token and r.purpose == ^purpose,
        limit: 1

    Repo.one(query)
  end

  def get_random_token!(%{login: email, purpose: purpose}) do
    query =
      from r in RandomTokens,
        where: r.login == ^String.downcase(email) and r.purpose == ^purpose,
        limit: 1

    Repo.one(query)
  end

  @doc """
  Creates a random_tokens.

  ## Examples

      iex> create_random_tokens(%{field: value})
      {:ok, %RandomTokens{}}

      iex> create_random_tokens(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_random_tokens(attrs \\ %{}) do
    %RandomTokens{}
    |> RandomTokens.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a random_tokens.

  ## Examples

      iex> update_random_tokens(random_tokens, %{field: new_value})
      {:ok, %RandomTokens{}}

      iex> update_random_tokens(random_tokens, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_random_tokens(%RandomTokens{} = random_tokens, attrs) do
    random_tokens
    |> RandomTokens.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RandomTokens.

  ## Examples

      iex> delete_random_tokens(random_tokens)
      {:ok, %RandomTokens{}}

      iex> delete_random_tokens(random_tokens)
      {:error, %Ecto.Changeset{}}

  """
  def delete_random_tokens(%RandomTokens{} = random_tokens) do
    Repo.delete(random_tokens)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking random_tokens changes.

  ## Examples

      iex> change_random_tokens(random_tokens)
      %Ecto.Changeset{source: %RandomTokens{}}

  """
  def change_random_tokens(%RandomTokens{} = random_tokens) do
    RandomTokens.changeset(random_tokens, %{})
  end

  @doc """
  Returns the list of email_categories.

  ## Examples

      iex> list_email_categories()
      [%EmailCategory{}, ...]

  """
  def list_email_categories do
    Repo.all(EmailCategory)
  end

  @doc """
  Gets a single email_category.

  Raises `Ecto.NoResultsError` if the Email category does not exist.

  ## Examples

      iex> get_email_category!(123)
      %EmailCategory{}

      iex> get_email_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email_category!(id), do: Repo.get!(EmailCategory, id)

  @doc """
  Creates a email_category.

  ## Examples

      iex> create_email_category(%{field: value})
      {:ok, %EmailCategory{}}

      iex> create_email_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email_category(attrs \\ %{}) do
    %EmailCategory{}
    |> EmailCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email_category.

  ## Examples

      iex> update_email_category(email_category, %{field: new_value})
      {:ok, %EmailCategory{}}

      iex> update_email_category(email_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_email_category(%EmailCategory{} = email_category, attrs) do
    email_category
    |> EmailCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a email_category.

  ## Examples

      iex> delete_email_category(email_category)
      {:ok, %EmailCategory{}}

      iex> delete_email_category(email_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_email_category(%EmailCategory{} = email_category) do
    Repo.delete(email_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_category changes.

  ## Examples

      iex> change_email_category(email_category)
      %Ecto.Changeset{source: %EmailCategory{}}

  """
  def change_email_category(%EmailCategory{} = email_category) do
    EmailCategory.changeset(email_category, %{})
  end

  @doc """
  Returns the list of email_settings.

  ## Examples

      iex> list_email_settings()
      [%EmailSetting{}, ...]

  """
  def list_email_settings do
    Repo.all(EmailSetting)
  end

  @doc """
  Gets a single email_setting.

  Raises `Ecto.NoResultsError` if the Email setting does not exist.

  ## Examples

      iex> get_email_setting!(123)
      %EmailSetting{}

      iex> get_email_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_email_setting!(id), do: Repo.get!(EmailSetting, id)
  def get_email_setting(id), do: Repo.get(EmailSetting, id)

  def get_email_settings_by_user(user_id) do
    from(es in EmailSetting, where: es.user_id == ^user_id)
    |> Repo.all()
  end

  def get_email_settings_by_category(user_id, category_id) do
    from(es in EmailSetting, where: es.category_id == ^category_id and es.user_id == ^user_id)
    |> Repo.all()
  end

  def get_email_settings_by_slug(user_id, slug) do
    from(es in EmailSetting, where: es.slug == ^slug and es.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Creates a email_setting.

  ## Examples

      iex> create_email_setting(%{field: value})
      {:ok, %EmailSetting{}}

      iex> create_email_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email_setting(attrs \\ %{}) do
    %EmailSetting{}
    |> EmailSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a email_setting.

  ## Examples

      iex> update_email_setting(email_setting, %{field: new_value})
      {:ok, %EmailSetting{}}

      iex> update_email_setting(email_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_email_setting(%EmailSetting{} = email_setting, attrs) do
    email_setting
    |> EmailSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a email_setting.

  ## Examples

      iex> delete_email_setting(email_setting)
      {:ok, %EmailSetting{}}

      iex> delete_email_setting(email_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_email_setting(%EmailSetting{} = email_setting) do
    Repo.delete(email_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking email_setting changes.

  ## Examples

      iex> change_email_setting(email_setting)
      %Ecto.Changeset{source: %EmailSetting{}}

  """
  def change_email_setting(%EmailSetting{} = email_setting) do
    EmailSetting.changeset(email_setting, %{})
  end
end
