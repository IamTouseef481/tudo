defmodule CoreWeb.GraphQL.Resolvers.LegalResolver do
  @moduledoc false
  alias Core.{Employees, Legals, MetaData, Regions}
  alias CoreWeb.Helpers.AdminNotificationSettingsHelper, as: ADS
  alias CoreWeb.Utils.CommonFunctions
  alias CoreWeb.Workers.{NotifyWorker, NotificationEmailsWorker}

  def get_all(_, _, _) do
    {:ok, Legals.list_platform_terms_and_conditions()}
  end

  def get_by(_, %{country_id: country_id}, _) do
    {:ok, Legals.get_platform_terms_and_conditions_by_country(country_id)}
  end

  def create_platform_term_and_condition(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      case Legals.create_platform_term_and_condition(input) do
        {:ok, %{type: type} = term} ->
          Task.start(
            __MODULE__,
            :update_user_terms_status,
            type: type
          )

          #        Absinthe.Subscription.publish(CoreWeb.Endpoint, user, create_user: true)
          {:ok, term}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def update_platform_term_and_condition(_, %{input: %{id: id} = input}, %{
        context: %{current_user: current_user}
      }) do
    if "web" in current_user.acl_role_id do
      case Legals.get_platform_term_and_condition(id) do
        nil ->
          {:error, ["Platform term and condition does not exist!"]}

        %{} = term ->
          case Legals.update_platform_term_and_condition(term, input) do
            {:ok, %{type: type} = term} ->
              Task.start(
                __MODULE__,
                :update_user_terms_status,
                type: type
              )

              #        Absinthe.Subscription.publish(CoreWeb.Endpoint, user, create_user: true)
              {:ok, term}

            {:error, error} ->
              {:error, error}
          end
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def accept_platform_term_and_condition(_, %{input: %{employee_id: employee_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    case Employees.get_employee(employee_id) do
      %{user_id: user_id, branch_id: branch_id} ->
        if user_id == current_user.id do
          case MetaData.get_dashboard_meta_by_employee_id(employee_id, branch_id, "dashboard") do
            [%{} = meta] ->
              case MetaData.update_meta_bsp(meta, input) do
                {:ok, meta} -> {:ok, meta}
                {:error, error} -> {:error, error}
              end

            _ ->
              {:error, ["can not accept term"]}
          end
        else
          {:error, ["You are not allowed to perform this action!"]}
        end

      _ ->
        {:error, ["You are not allowed to perform this action!"]}
    end
  end

  def accept_platform_term_and_condition(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    case MetaData.get_dashboard_meta_by_user_id(current_user.id, "dashboard") do
      [%{} = meta] ->
        case MetaData.update_meta_cmr(meta, input) do
          {:ok, meta} -> {:ok, meta}
          {:error, error} -> {:error, error}
        end

      _ ->
        {:error, ["can not accept term"]}
    end
  end

  def get_licence_issuing_authorities_by_country(_, %{input: %{country_id: country_id}}, _) do
    {:ok, Legals.get_licence_issuing_authorities_by_country(country_id)}
  end

  def update_user_terms_status({:type, "cmr"}) do
    MetaData.list_meta_cmr_preloaded_user_and_installs()
    |> Enum.map(fn meta ->
      MetaData.update_meta_cmr(meta, %{terms_accepted: false})
      send_notification_and_email(meta.user)
    end)
  end

  def update_user_terms_status({:type, "bsp"}) do
    MetaData.list_meta_bsp_preloaded_user_and_installs()
    |> Enum.map(fn meta ->
      MetaData.update_meta_bsp(meta, %{terms_accepted: false})
      send_notification_and_email(meta.user)
    end)
  end

  def send_notification_and_email(%{
        id: user_id,
        email: email,
        user_installs: user_installs,
        acl_role_id: roles,
        language_id: lang_id
      }) do
    language = get_language(lang_id) |> String.downcase()
    {year, _, _} = Date.utc_today() |> Date.to_erl()
    email_attrs = %{"language" => language, "email" => email, "year" => year, "terms" => ""}
    role = CommonFunctions.check_user_role(roles)

    if ADS.check_admin_notification_permission(role, "update_platform_terms") do
      send_notification(user_installs, user_id, "update_platform_terms", role, language)
    end

    #    emails admin validation is handled in NotifyWorkerWorker worker
    NotificationEmailsWorker.perform("update_platform_terms", email_attrs, role)
    {:ok, "notifications and emails sent"}
  end

  def send_notification_and_email(_) do
    {:ok, "notifications and emails not sent"}
  end

  defp send_notification(
         user_installs,
         user_id,
         msg_id,
         user_role,
         lan,
         params \\ %{},
         silent_push \\ false
       ) do
    Enum.map(user_installs, fn %{os: device, fcm_token: device_id} ->
      NotifyWorker.send_notification_for_single_device(
        msg_id,
        user_id,
        user_role,
        lan,
        device,
        device_id,
        params,
        silent_push
      )
    end)
  end

  defp get_language(language_id) do
    if language_id == nil do
      "EN"
    else
      %{code: language} = Regions.get_languages(language_id)
      language
    end
  end
end
