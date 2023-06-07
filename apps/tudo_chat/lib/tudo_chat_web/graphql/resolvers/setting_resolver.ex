defmodule TudoChatWeb.GraphQL.Resolvers.SettingResolver do
  @moduledoc false
  alias TudoChat.Settings
  alias TudoChatWeb.Controllers.SettingController
  alias TudoChatWeb.Utils.CommonFunctions

  def list_settings(_, _, _) do
    {:ok, Settings.list_settings()}
  end

  def list_group_settings(_, _, _) do
    {:ok, Settings.list_group_settings()}
  end

  def settings_by_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})
    {:ok, Settings.settings_by_type(input)}
  end

  def create_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    input =
      if Map.has_key?(input, :fields) do
        Map.merge(input, %{fields: CommonFunctions.string_to_map(input.fields)})
      else
        input
      end

    case SettingController.create_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end

  def update_settings(_, %{input: %{setting_id: _setting_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    input =
      if Map.has_key?(input, :fields) do
        Map.merge(input, %{fields: CommonFunctions.string_to_map(input.fields)})
      else
        input
      end

    case SettingController.update_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end

  def get_group_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})
    {:ok, Settings.group_settings(input)}
  end

  def create_group_settings(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    input =
      if Map.has_key?(input, :fields) do
        Map.merge(input, %{fields: CommonFunctions.string_to_map(input.fields)})
      else
        input
      end

    case SettingController.create_group_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end

  def update_group_settings(_, %{input: %{setting_id: _setting_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    input = Map.merge(input, %{user_id: current_user.id})

    input =
      if Map.has_key?(input, :fields) do
        Map.merge(input, %{fields: CommonFunctions.string_to_map(input.fields)})
      else
        input
      end

    case SettingController.update_group_setting(input) do
      {:ok, setting} -> {:ok, setting}
      {:error, error} -> {:error, error}
    end
  end
end
