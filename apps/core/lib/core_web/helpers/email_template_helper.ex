defmodule CoreWeb.Helpers.EmailTemplateHelper do
  #   Core.CashFree.Sages.Order

  @moduledoc false
  use CoreWeb, :core_helper
  alias Core.{Emails, Employees}
  alias CoreWeb.Workers.NotificationEmailsWorker

  def create_email_template(params) do
    new()
    |> run(:check, &check_if_template_exist/2, &abort/3)
    |> run(:get_email_template, &get_email_template/2, &abort/3)
    |> run(:bsp_email_template, &create_email_template/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def create_bsp_email_template(params) do
    new()
    |> run(:check_user, &check_user_for_branch/2, &abort/3)
    |> run(:check_template, &check_locally_if_template_exist/2, &abort/3)
    |> run(:get_bsp_email_template, &get_bsp_email_template/2, &abort/3)
    |> run(:bsp_email_template, &create_bsp_email_template/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def update_bsp_email_template(params) do
    new()
    |> run(:check_user, &check_user_for_branch/2, &abort/3)
    |> run(:check_template, &check_locally_if_template_exist/2, &abort/3)
    |> run(:update_bsp_email_template, &update_bsp_email_template/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def bsp_email_templates(params) do
    new()
    |> run(:check_user, &check_user_for_branch/2, &abort/3)
    |> run(:email_templates, &get_email_templates/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def check_if_template_exist(_, params) do
    template_id =
      params[:send_in_blue_email_template_id] || params[:send_in_blue_notification_template_id]

    case NotificationEmailsWorker.getting_sendinblue_email_template_by(template_id) do
      {:ok, _} -> {:ok, ["valid"]}
      {:error, error} -> {:error, error}
      _ -> {:error, "Template id #{template_id} does not exist"}
    end
  end

  def get_email_template(_, input) do
    case Emails.get_by_apply_filter(input) do
      nil -> {:ok, :create}
      data -> {:ok, data}
    end
  end

  def create_email_template(%{get_email_template: :create}, params) do
    case Emails.create_email_templates(params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_email_template(%{get_email_template: data}, params) do
    case Emails.update_email_templates(data, Map.drop(params, [:id])) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      _ -> {:error, ["Cannot update email template"]}
    end
  end

  def check_locally_if_template_exist(_, params) do
    case Emails.get_by_apply_filter(Map.merge(params, %{slug: params.action})) do
      nil -> {:error, "Template not found"}
      _data -> {:ok, ["valid"]}
    end
  end

  def check_user_for_branch(_, %{branch_id: branch_id, user_id: user_id}) do
    case Employees.check_branch_owner_or_branch_manager(user_id, branch_id) do
      false -> {:error, "You are not the owner or branch_manager of this branch"}
      true -> {:ok, ["valid"]}
    end
  end

  def create_bsp_email_template(%{get_bsp_email_template: :create}, params) do
    case Emails.create_bsp_email_template(params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_bsp_email_template(%{get_bsp_email_template: bsp_email_template}, params) do
    case Emails.update_bsp_email_template(bsp_email_template, params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_bsp_email_template(_, %{
        action: action,
        branch_id: branch_id,
        application_id: application_id
      }) do
    case Emails.get_bsp_email_template_by(action, application_id, branch_id) do
      nil -> {:ok, :create}
      data -> {:ok, data}
    end
  end

  def update_bsp_email_template(_, %{bsp_email_template: bsp_email_template} = params) do
    case Emails.update_bsp_email_template(bsp_email_template, params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: [{k, {msg, _}} | _]}} -> {:error, "#{k} " <> "#{msg}"}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_email_templates(_, input), do: {:ok, Emails.apply_filter(input)}
end
