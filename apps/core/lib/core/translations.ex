defmodule Core.Translations do
  @moduledoc """
  The Translations context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Schemas.{Screen, Translation}

  @doc """
  Returns the list of screens.

  ## Examples

      iex> list_screens()
      [%Screen{}, ...]

  """
  def list_screens do
    Repo.all(Screen)
  end

  @doc """
  Gets a single screen.

  Raises `Ecto.NoResultsError` if the Screen does not exist.

  ## Examples

      iex> get_screen!(123)
      %Screen{}

      iex> get_screen!(456)
      ** (Ecto.NoResultsError)

  """
  def get_screen!(id), do: Repo.get!(Screen, id)

  @doc """
  Creates a screen.

  ## Examples

      iex> create_screen(%{field: value})
      {:ok, %Screen{}}

      iex> create_screen(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_screen(attrs \\ %{}) do
    %Screen{}
    |> Screen.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a screen.

  ## Examples

      iex> update_screen(screen, %{field: new_value})
      {:ok, %Screen{}}

      iex> update_screen(screen, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_screen(%Screen{} = screen, attrs) do
    screen
    |> Screen.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a screen.

  ## Examples

      iex> delete_screen(screen)
      {:ok, %Screen{}}

      iex> delete_screen(screen)
      {:error, %Ecto.Changeset{}}

  """
  def delete_screen(%Screen{} = screen) do
    Repo.delete(screen)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking screen changes.

  ## Examples

      iex> change_screen(screen)
      %Ecto.Changeset{source: %Screen{}}

  """
  def change_screen(%Screen{} = screen) do
    Screen.changeset(screen, %{})
  end

  @doc """
  Returns the list of translations.

  ## Examples

      iex> list_translations()
      [%Translation{}, ...]

  """
  def list_translations do
    Repo.all(Translation)
  end

  @doc """
  Gets a single translation.

  Raises `Ecto.NoResultsError` if the Translation does not exist.

  ## Examples

      iex> get_translation!(123)
      %Translation{}

      iex> get_translation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_translation!(id), do: Repo.get!(Translation, id)

  @doc """
  Creates a translation.

  ## Examples

      iex> create_translation(%{field: value})
      {:ok, %Translation{}}

      iex> create_translation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_translation(attrs \\ %{}) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update_translation(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update_translation(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_translation(%Translation{} = translation, attrs) do
    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a translation.

  ## Examples

      iex> delete_translation(translation)
      {:ok, %Translation{}}

      iex> delete_translation(translation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_translation(%Translation{} = translation) do
    Repo.delete(translation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation changes.

  ## Examples

      iex> change_translation(translation)
      %Ecto.Changeset{source: %Translation{}}

  """
  def change_translation(%Translation{} = translation) do
    Translation.changeset(translation, %{})
  end
end
