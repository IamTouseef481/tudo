defmodule TudoChatWeb.Controllers.SearchPersonController do
  @moduledoc false
  use TudoChatWeb, :controller

  @common_error ["no results found"]

  def search_persons(%{email: email} = _input) do
    case Core.Accounts.get_public_user_by_email(email) do
      %{profile: profile} = person ->
        {:ok, Map.merge(person, keys_to_atoms(profile))}

      nil ->
        {:error, @common_error}
    end
  end

  def search_persons(%{mobile: mobile} = _input) do
    case Core.Accounts.get_public_user_by_mobile(mobile) do
      [] ->
        {:error, @common_error}

      persons ->
        {:ok, Enum.map(persons, &Map.merge(&1, keys_to_atoms(&1.profile)))}
    end
  end

  def search_persons(%{name: name} = _input) do
    case String.split(name, " ") do
      [first_name | [last_name | _]] ->
        search_person_by_first_and_last_name(first_name, last_name)

      [name] ->
        search_person_by_first_or_last_name(name)

      _ ->
        {:error, ["Something went wrong, try again!"]}
    end
  end

  def search_persons(_) do
    {:error, ["no email or name in params!"]}
  end

  defp search_person_by_first_or_last_name(name) do
    case Core.Accounts.search_person_by_first_or_last_name(name) do
      [] ->
        {:error, @common_error}

      persons ->
        {:ok, Enum.map(persons, &Map.merge(&1, keys_to_atoms(&1.profile)))}
    end
  end

  defp search_person_by_first_and_last_name(first_name, last_name) do
    case Core.Accounts.search_person_by_first_and_last_name(first_name, last_name) do
      [] ->
        {:error, @common_error}

      persons ->
        {:ok, Enum.map(persons, &Map.merge(&1, keys_to_atoms(&1.profile)))}
    end
  end
end
