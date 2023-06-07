defmodule CoreWeb.Helpers.ValidateEmployeeParamsHelper do
  # Core.Employees.ValidateEmployeeParams.Sages
  @moduledoc false
  use CoreWeb, :core_helper
  import CoreWeb.Utils.Errors
  alias Core.Employees
  alias Core.Schemas.Employee

  #
  # Main actions
  #

  def validate(params) do
    new()
    |> run(:verify_scheduled_jobs, &verify_scheduled_jobs_on_making_employee_inactive/2, &abort/3)
    |> run(:validate_employee_params, &validate_employee_params/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  defp verify_scheduled_jobs_on_making_employee_inactive(_, %{id: id, employee_status_id: status}) do
    if status in ["terminated", "retired"] do
      case Core.Calendars.get_calendar_by_employee(id) do
        %{schedule: %{"jobs" => []}} ->
          {:ok, ["valid"]}

        %{schedule: %{"jobs" => _jobs}} ->
          {:error, ["Reassign scheduled Jobs before In-activating the Employee status."]}

        _ ->
          {:error, ["Error in fetching calendar, try again"]}
      end
    else
      {:ok, ["valid"]}
    end
  end

  defp verify_scheduled_jobs_on_making_employee_inactive(_, _) do
    {:ok, ["valid, no ongoing job"]}
  end

  defp validate_employee_params(
         _,
         %{id: id, manager_id: manager_id, branch_id: branch_id} = _params
       ) do
    case validate_employee_params(id, %{id: id, manager_id: manager_id}) do
      {:ok, _data} -> validate_employee_params(id, %{id: id, branch_id: branch_id})
      {:error, error} -> {:error, error}
      _ -> {:error, ["invalid data!"]}
    end
  end

  defp validate_employee_params(_, %{id: id, manager_id: manager_id}) do
    employee_business_id = Employees.get_business_by_employee(id)

    case Employees.get_branch_manager_by_manager_id(manager_id) do
      nil ->
        {:error, ["Manager user doesn't exist!"]}

      %Employee{} = manager ->
        manager_business_id = Employees.get_business_by_employee(manager.id)

        if employee_business_id == manager_business_id do
          {:ok, manager}
        else
          {:error, ["Manager user do not exist under this Business!"]}
        end

      exception ->
        logger(__MODULE__, exception, ["Invalid Manager user!"], __ENV__.line)
    end
  end

  defp validate_employee_params(_, %{id: id, branch_id: branch_id}) do
    employee_business_id = Employees.get_business_by_employee(id)
    branch_business = Core.BSP.get_branch!(branch_id)

    if employee_business_id == branch_business.business_id do
      {:ok, branch_business}
    else
      {:error, ["invalid branch"]}
    end
  end

  defp validate_employee_params(_, _) do
    {:ok, ["valid"]}
  end

  def is_manager_exist(%{manager_id: manager_id, branch_id: employee_branch_id}) do
    case Employees.get_branch_manager_by_manager_id(manager_id) do
      nil ->
        {:error, ["Manager user doesn't exist!"]}

      %Employee{} = manager ->
        manager_branch_id = Employees.get_branch_by_employee(manager.id)

        if manager_branch_id == employee_branch_id do
          {:ok, ["valid"]}
        else
          {:error, ["Manager user doesn't belong to the Branch!"]}
        end

      _ ->
        {:error, ["Unable to validate Manager user!"]}
    end
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{approved_by_id: _approved_by_id, id: _id} = params
      ) do
    params = Map.merge(params, %{employee_status_id: "active"})
    Employees.update_employee(changeset, params)
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{
          personal_identification: %{rest_documents_photos: documents_photos} = pi,
          rest_photos: rest_photos
        } = params
      ) do
    personal_identification =
      case pi do
        %{documents: documents} -> %{documents: documents, documents_photos: documents_photos}
        _ -> %{documents_photos: documents_photos}
      end

    params =
      Map.merge(params, %{
        personal_identification: personal_identification,
        photos: rest_photos,
        employee_status_id: "pending_approval"
      })

    data = Core.Schemas.Employee.invite_changeset(%Core.Schemas.Employee{}, params)
    Employees.update_employee(changeset, data.changes)
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{
          personal_identification: %{rest_documents_photos: documents_photos} = pi
        } = params
      ) do
    personal_identification =
      case pi do
        %{documents: documents} -> %{documents: documents, documents_photos: documents_photos}
        _ -> %{documents_photos: documents_photos}
      end

    params =
      Map.merge(params, %{
        personal_identification: personal_identification,
        employee_status_id: "pending_approval"
      })

    Employees.update_employee(changeset, params)
  end

  def update_employee(%{is_employee_record_exist: changeset}, %{rest_photos: photos} = params) do
    params = Map.merge(params, %{photos: photos, employee_status_id: "pending_approval"})
    Employees.update_employee(changeset, params)
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{
          personal_identification: %{documents_photos: documents_photos} = pi,
          photos: photos
        } = params
      ) do
    documents_photos = CoreWeb.Controllers.ImageController.upload(documents_photos, "services")
    files = CoreWeb.Controllers.ImageController.upload(photos, "services")

    personal_identification =
      case pi do
        %{documents: documents} -> %{documents: documents, documents_photos: documents_photos}
        _ -> %{documents_photos: documents_photos}
      end

    params =
      Map.merge(params, %{
        personal_identification: personal_identification,
        photos: files,
        employee_status_id: "pending_approval"
      })

    data = Core.Schemas.Employee.invite_changeset(%Core.Schemas.Employee{}, params)
    Employees.update_employee(changeset, data.changes)
  end

  def update_employee(%{is_employee_record_exist: changeset}, %{photos: photos} = params) do
    files = CoreWeb.Controllers.ImageController.upload(photos, "services")

    params =
      Map.merge(params, %{
        photos: files,
        employee_status_id: "pending_approval"
      })

    data = Core.Schemas.Employee.invite_changeset(%Core.Schemas.Employee{}, params)
    Employees.update_employee(changeset, data.changes)
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{
          personal_identification: %{documents_photos: documents_photos} = pi
        } = params
      ) do
    documents_photos = CoreWeb.Controllers.ImageController.upload(documents_photos, "services")

    personal_identification =
      case pi do
        %{documents: documents} -> %{documents: documents, documents_photos: documents_photos}
        _ -> %{documents_photos: documents_photos}
      end

    params =
      Map.merge(params, %{
        personal_identification: personal_identification,
        employee_status_id: "pending_approval"
      })

    data = Core.Schemas.Employee.invite_changeset(%Core.Schemas.Employee{}, params)
    Employees.update_employee(changeset, data.changes)
  end

  def update_employee(
        %{is_employee_record_exist: changeset},
        %{
          personal_identification: %{documents_photos: documents_photos, documents: documents}
        } = params
      ) do
    documents_photos = CoreWeb.Controllers.ImageController.upload(documents_photos, "services")

    params =
      Map.merge(params, %{
        personal_identification: %{
          documents_photos: documents_photos,
          documents: documents
        },
        employee_status_id: "pending_approval"
      })

    Employees.update_employee(changeset, params)
  end

  def update_employee(%{is_employee_record_exist: changeset}, params) do
    data = Core.Schemas.Employee.invite_changeset(%Core.Schemas.Employee{}, params)
    Employees.update_employee(changeset, data.changes)
  end
end
