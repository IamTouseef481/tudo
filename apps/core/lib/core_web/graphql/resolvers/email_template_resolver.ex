defmodule CoreWeb.GraphQL.Resolvers.EmailTemplateResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.Emails
  alias CoreWeb.Controllers.EmailTemplatesController

  def list_email_templates(_, %{slug: slug}, _) do
    {:ok, Emails.list_email_templates(slug)}
  end

  def list_email_templates(_, _, _) do
    {:ok, Emails.list_email_templates()}
  end

  def list_application(_, _) do
    {:ok, Emails.list_application()}
  end

  def delete_email_templates(_, %{input: %{id: id}}, _) do
    case Emails.get_email_templates!(id) do
      nil -> {:error, "email template does not exist"}
      data -> Emails.delete_email_templates(data)
    end
  end

  def send_in_blue_email_attributes(_, _, _) do
    {:ok, CoreWeb.Workers.NotificationEmailsWorker.getting_template_attributes()}
  end

  def create_email_template(_, %{input: input}, %{
        context: %{current_user: %{acl_role_id: acl_role_id}}
      }) do
    if "web" in acl_role_id do
      case EmailTemplatesController.create_email_template(input) do
        {:ok, data} -> {:ok, data}
        {:error, error} -> {:error, error}
      end
    else
      {:error, ["You are not admin"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create email template"], __ENV__.line)
  end
end
