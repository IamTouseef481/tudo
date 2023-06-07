defmodule CoreWeb.Controllers.EmailTemplatesController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.Emails
  alias Core.Schemas.EmailTemplates
  alias CoreWeb.Helpers.EmailTemplateHelper

  def index(conn, _params) do
    email_templates = Emails.list_email_templates()
    render(conn, "index.html", email_templates: email_templates)
  end

  def new(conn, _params) do
    changeset = Emails.change_email_templates(%EmailTemplates{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email_templates" => email_templates_params}) do
    case Emails.create_email_templates(email_templates_params) do
      {:ok, _email_templates} ->
        conn
        |> put_flash(:info, "Email templates created successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    email_templates = Emails.get_email_templates!(id)
    render(conn, "show.html", email_templates: email_templates)
  end

  def edit(conn, %{"id" => id}) do
    email_templates = Emails.get_email_templates!(id)
    changeset = Emails.change_email_templates(email_templates)
    render(conn, "edit.html", email_templates: email_templates, changeset: changeset)
  end

  def update(conn, %{"id" => id, "email_templates" => email_templates_params}) do
    email_templates = Emails.get_email_templates!(id)

    case Emails.update_email_templates(email_templates, email_templates_params) do
      {:ok, _email_templates} ->
        conn
        |> put_flash(:info, "Email templates updated successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", email_templates: email_templates, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    email_templates = Emails.get_email_templates!(id)
    {:ok, _email_templates} = Emails.delete_email_templates(email_templates)

    conn
    |> put_flash(:info, "Email templates deleted successfully.")
  end

  def create_email_template(input) do
    {:ok,
     Enum.reduce(input.email_templates, [], fn email_template, acc ->
       with {:ok, _last, all} <- EmailTemplateHelper.create_email_template(email_template),
            %{bsp_email_template: data} <- all do
         [data | acc]
       else
         {:error, error} -> [%{message: error} | acc]
         all -> {:error, all}
       end
     end)}
  end

  def create_bsp_email_template(input) do
    with {:ok, _last, all} <- EmailTemplateHelper.create_bsp_email_template(input),
         %{bsp_email_template: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  end

  def update_bsp_email_template(input) do
    with {:ok, _last, all} <- EmailTemplateHelper.update_bsp_email_template(input),
         %{update_bsp_email_template: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  end

  def bsp_email_templates(input) do
    with {:ok, _last, all} <- EmailTemplateHelper.bsp_email_templates(input),
         %{email_templates: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  end
end
