defmodule CoreWeb.GraphQL.Resolvers.BspEmailTemplateResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias CoreWeb.Controllers.EmailTemplatesController
  alias Core.Emails

  def create_bsp_email_template(_, %{input: input}, %{
        context: %{current_user: current_user}
      }) do
    if is_nil(
         input[:send_in_blue_email_template_id] || input[:send_in_blue_notification_template_id]
       ) do
      {:error, ["Templete id is missing"]}
    else
      case EmailTemplatesController.create_bsp_email_template(
             Map.merge(input, %{user_id: current_user.id})
           ) do
        {:ok, data} -> {:ok, data}
        {:error, error} -> {:error, error}
      end
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create bsp email template"], __ENV__.line)
  end

  def update_bsp_email_template(_, %{input: input}, %{context: %{current_user: current_user}}) do
    if is_nil(
         input[:send_in_blue_email_template_id] || input[:send_in_blue_notification_template_id]
       ) do
      {:error, ["Templete id is missing"]}
    else
      case Emails.get_bsp_email_template!(input.id) do
        nil ->
          {:error, "No bsp email template found"}

        data ->
          Map.merge(input, %{
            user_id: current_user.id,
            bsp_email_template: data,
            branch_id: data.branch_id,
            action: data.action
          })
          |> EmailTemplatesController.update_bsp_email_template()
      end
    end
  end

  def bsp_email_templates(_, %{input: input}, %{context: %{current_user: current_user}}) do
    EmailTemplatesController.bsp_email_templates(Map.merge(input, %{user_id: current_user.id}))
  rescue
    exception ->
      logger(__MODULE__, exception, [], __ENV__.line)
  end

  def delete_bsp_email_template(_, %{input: %{id: id}}, %{
        context: %{current_user: _current_user}
      }) do
    case Emails.get_bsp_email_template!(id) do
      nil -> {:error, "No bsp email template found"}
      data -> Emails.delete_bsp_email_template(data)
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to delete bsp email template"], __ENV__.line)
  end
end
