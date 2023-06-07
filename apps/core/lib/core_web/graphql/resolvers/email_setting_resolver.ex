defmodule CoreWeb.GraphQL.Resolvers.EmailSettingResolver do
  @moduledoc false
  alias Core.Emails

  def get_email_settings_by_user(_, _, %{context: %{current_user: current_user}}) do
    {:ok, Emails.get_email_settings_by_user(current_user.id)}
  end

  def update_email_settings(_, %{input: %{category_id: category_id, is_active: is_active}}, %{
        context: %{current_user: current_user}
      }) do
    email_settings = Emails.get_email_settings_by_category(current_user.id, category_id)

    settings =
      Enum.reduce(email_settings, [], fn setting, acc ->
        case Emails.update_email_setting(setting, %{is_active: is_active}) do
          {:ok, data} -> [data | acc]
          _ -> acc
        end
      end)

    {:ok, settings}
  end

  def update_email_settings(_, %{input: %{slug: slug, is_active: is_active}}, %{
        context: %{current_user: current_user}
      }) do
    email_settings = Emails.get_email_settings_by_slug(current_user.id, slug)

    settings =
      Enum.reduce(email_settings, [], fn setting, acc ->
        case Emails.update_email_setting(setting, %{is_active: is_active}) do
          {:ok, data} -> [data | acc]
          _ -> acc
        end
      end)

    {:ok, settings}
  end
end
