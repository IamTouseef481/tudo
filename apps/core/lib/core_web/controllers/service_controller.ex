defmodule CoreWeb.Controllers.ServiceController do
  @moduledoc false

  use CoreWeb, :controller

  alias Core.{BSP, Employees, Services}
  alias Core.Schemas.{Service, ServiceSetting}
  alias CoreWeb.Helpers.ServiceHelper

  def create_service_setting(%{fields: fields} = input) do
    input = Map.merge(input, %{fields: string_to_map(fields)})

    case Services.get_service_setting_by_country_service_id(input.country_service_id) do
      [] -> Services.create_service_setting(input)
      _ -> {:error, ["Data already exists!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def create_service_setting(input) do
    case Services.get_service_setting_by_country_service_id(input.country_service_id) do
      [] -> Services.create_service_setting(input)
      _ -> {:error, ["Data already exists!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def update_service_setting(%{id: id, fields: fields} = input) do
    input = Map.merge(input, %{fields: string_to_map(fields)})

    case Services.get_service_setting!(id) do
      %ServiceSetting{} = data -> Services.update_service_setting(data, input)
      _ -> {:error, ["Data doesn't exist!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def update_service_setting(%{id: id} = input) do
    case Services.get_service_setting!(id) do
      %ServiceSetting{} = data -> Services.update_service_setting(data, input)
      _ -> {:error, ["Data doesn't exist!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_service_setting(%{id: id}) do
    case Services.get_service_setting!(id) do
      %ServiceSetting{} = data -> Services.delete_service_setting(data)
      _ -> {:error, ["Data doesn't exist!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_service_group(%{name: name} = input) do
    case Services.get_service_group(name: name) do
      nil -> Services.create_service_group(input)
      _ -> {:error, ["Data already exists!"]}
    end
  end

  def update_service_group(%{id: id} = input) do
    case Services.get_service_group(id: id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> Services.update_service_group(data, input)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_service_group(%{id: id}) do
    case Services.get_service_group(id: id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> Services.delete_service_group(data)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def get_service_group(%{id: id}) do
    case Services.get_service_group(id: id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> {:ok, data}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_service_status(input) do
    if owner_or_manager_validity(input) do
      case Services.create_service_status(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_service_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_status -> {:ok, service_status}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_service_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_status -> Services.update_service_status(service_status, input)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_service_status(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_status(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_status -> Services.delete_service_status(service_status)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_service_type(input) do
    if owner_or_manager_validity(input) do
      case Services.create_service_type(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def get_service_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_type(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_type -> {:ok, service_type}
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't retrieve"]}
  end

  def update_service_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_type(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_type -> Services.update_service_type(service_type, input)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_service_type(%{id: id} = input) do
    if owner_or_manager_validity(input) do
      case Services.get_service_type(id) do
        nil -> {:error, ["doesn't exist!"]}
        %{} = service_type -> Services.delete_service_type(service_type)
        _ -> {:error, ["Unexpected error occurred, try again!"]}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_service(%{name: name} = input) do
    case Services.get_service_by(name: name) do
      nil -> Services.create_service(input)
      _ -> {:error, ["Data already exists!"]}
    end
  end

  def update_service(%{id: id} = input) do
    case Services.get_service(id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> Services.update_service(data, input)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't update"]}
  end

  def delete_service(%{id: id}) do
    case Services.get_service(id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> Services.delete_service(data)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def create_country_service(params) do
    with {:ok, _last, all} <- ServiceHelper.create_country_service(params),
         %{country_service: country_service} <- all do
      {:ok, country_service}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def update_country_service(params) do
    with {:ok, _last, all} <- ServiceHelper.update_country_service(params),
         %{country_service: country_service} <- all do
      {:ok, country_service}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end

  def delete_country_service(%{id: id}) do
    case Services.get_country_service(id) do
      nil -> {:error, ["Data doesn't exist!"]}
      data -> Services.delete_country_service(data)
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def validity_for_branch_services(%{user_id: user_id, branch_id: branch_id}) do
    if Employees.get_owner_or_manager_by_user_and_branch(user_id, branch_id) != nil or
         BSP.get_branch_by_user(%{id: branch_id, user_id: user_id}) != nil do
      true
    else
      false
    end
  end

  def create_branch_service(%{branch_id: branch_id, user_id: user_id} = input) do
    if validity_for_branch_services(%{user_id: user_id, branch_id: branch_id}) do
      with {:ok, _last, all} <- ServiceHelper.create_branch_service(input),
           %{branch_service: data} <- all do
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    _ -> {:error, ["Something went wrong, can't insert"]}
  end

  def update_branch_service(
        %{branch_id: branch_id} = _branch_service,
        %{user_id: user_id} = params
      ) do
    if validity_for_branch_services(%{user_id: user_id, branch_id: branch_id}) do
      with {:ok, _last, all} <- ServiceHelper.update_branch_service(params),
           %{branch_service: data} <- all do
        {:ok, data}
      else
        {:error, error} -> {:error, error}
        all -> {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    all -> all
  end

  def update_multiple_branch_services(
        %{branch_id: branch_id, service_type_id: service_type, user_id: user_id} = params
      ) do
    if validity_for_branch_services(%{user_id: user_id, branch_id: branch_id}) do
      case check_foreign_keys(params) do
        {:ok, _data} ->
          branch_services =
            Services.get_branch_services_by_service_type(%{service_type_id: service_type})

          branch_services =
            Enum.reduce(branch_services, [], fn bs, acc ->
              case Services.update_branch_service(bs, params) do
                {:ok, data} -> [data | acc]
                {:error, _} -> acc
                _ -> acc
              end
            end)

          {:ok, branch_services}

        {:error, error} ->
          {:error, error}

        all ->
          {:error, all}
      end
    else
      {:error, ["You are not allowed to perform this action!"]}
    end
  rescue
    all -> all
  end

  def get_branch_services_by_branch(%{branch_id: branch_id}) do
    case Services.get_branch_services_by_branch(branch_id) do
      branch_services -> {:ok, branch_services}
    end
  end

  def delete_branch_service(%{id: id, user_id: user_id} = input) do
    case Services.get_branch_service(id) do
      nil ->
        {:error, ["Data doesn't exist!"]}

      %{branch_id: branch_id} ->
        if validity_for_branch_services(%{user_id: user_id, branch_id: branch_id}) do
          with {:ok, _last, all} <- ServiceHelper.delete_branch_service(input),
               %{branch_service: data} <- all do
            {:ok, data}
          else
            {:error, error} -> {:error, error}
            all -> {:error, all}
          end
        else
          {:error, ["You are not allowed to perform this action!"]}
        end
    end
  rescue
    _ -> {:error, ["Something went wrong, can't delete"]}
  end

  def check_foreign_keys(params) do
    with {:ok, _data} <- check_branch(params),
         {:ok, _data} <- check_service_type(params) do
      {:ok, {"valid"}}
    else
      {error, error} -> {:error, error}
    end
  end

  def check_branch(%{branch_id: branch_id}) do
    case BSP.get_branch!(branch_id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{} = branch -> {:ok, branch}
      _ -> {:error, ["enable to fetch branch!"]}
    end
  end

  def check_branch(_params) do
    {:ok, ["valid"]}
  end

  def check_service_type(%{service_type_id: service_type_id}) do
    case Services.get_service_type(service_type_id) do
      nil -> {:error, ["doesn't exist!"]}
      %{} = service_type -> {:ok, service_type}
      _ -> {:error, ["enable to fetch service type"]}
    end
  end

  def check_service_type(_params) do
    {:ok, ["valid"]}
  end

  def index(conn, _params) do
    services = Services.list_services()
    render(conn, "index.html", services: services)
  end

  def new(conn, _params) do
    changeset = Services.change_service(%Service{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"service" => service_params}) do
    case Services.create_service(service_params) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service created successfully.")

      # |> redirect(to: Routes.service_path(conn, :show, service))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    service = Services.get_service!(id)
    render(conn, "show.html", service: service)
  end

  def edit(conn, %{"id" => id}) do
    service = Services.get_service!(id)
    changeset = Services.change_service(service)
    render(conn, "edit.html", service: service, changeset: changeset)
  end

  def update(conn, %{"id" => id, "service" => service_params}) do
    service = Services.get_service!(id)

    case Services.update_service(service, service_params) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service updated successfully.")

      # |> redirect(to: Routes.service_path(conn, :show, service))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", service: service, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    service = Services.get_service!(id)
    {:ok, _service} = Services.delete_service(service)

    conn
    |> put_flash(:info, "Service deleted successfully.")

    # |> redirect(to: Routes.service_path(conn, :index))
  end

  def create_services_along_with_country_services(params) do
    with {:ok, _last, all} <-
           ServiceHelper.create_services_along_with_country_services_sage(params),
         %{create_service: create_service} <- all do
      {:ok, create_service}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    all -> all
  end
end
