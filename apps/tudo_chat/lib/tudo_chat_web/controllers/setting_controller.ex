defmodule TudoChatWeb.Controllers.SettingController do
  @moduledoc false
  use TudoChatWeb, :controller
  alias TudoChat.Settings
  alias TudoChat.Settings.Setting

  @common_error ["Something went wrong, try again!"]

  def create_setting(%{user_id: user_id, slug: slug} = input) do
    case Settings.settings_by_slug(%{user_id: user_id, slug: slug}) do
      [] ->
        case Settings.create_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, _} -> {:error, @common_error}
        end

      _settings ->
        {:error, ["setting of this user against this slug already exist!"]}
    end
  end

  def update_setting(%{setting_id: setting_id} = input) do
    case Settings.get_setting(setting_id) do
      nil -> {:error, ["settings does not exist!"]}
      %Setting{} = setting -> update_setting(setting, input)
    end
  end

  defp update_setting(old_settings, params) do
    case Settings.update_setting(old_settings, params) do
      {:ok, setting} -> {:ok, setting}
      {:error, _} -> {:error, @common_error}
    end
  end

  #   -----------------    group setting   ---------------
  def create_group_setting(%{user_id: _user_id, slug: _slug} = input) do
    case Settings.group_settings_by_slug(input) do
      [] ->
        case Settings.create_group_setting(input) do
          {:ok, setting} -> {:ok, setting}
          {:error, _} -> {:error, @common_error}
        end

      _settings ->
        {:error, ["setting already exist!"]}
    end
  end

  def update_group_setting(%{setting_id: setting_id} = input) do
    case Settings.get_group_setting(setting_id) do
      nil ->
        {:error, ["settings does not exist!"]}

      %{} = setting ->
        update_group_setting(setting, input)
    end
  end

  defp update_group_setting(old_settings, params) do
    case Settings.update_group_setting(old_settings, params) do
      {:ok, setting} -> {:ok, setting}
      {:error, _} -> {:error, @common_error}
    end
  end
end
