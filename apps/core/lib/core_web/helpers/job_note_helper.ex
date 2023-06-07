defmodule CoreWeb.Helpers.JobNoteHelper do
  @moduledoc false
  use CoreWeb, :core_helper

  alias Core.{Jobs, BSP, Accounts}
  alias Core.Schemas.{Job}

  def create_job_note(params) do
    new()
    |> run(:is_job_exist, &is_job_exist/2, &abort/3)
    |> run(:verify_note_type, &verify_note_type/2, &abort/3)
    |> run(:create_job_note, &create_job_note/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def show_job_note(params) do
    new()
    |> run(:is_job_exist, &is_job_exist/2, &abort/3)
    |> run(:show_job_note, &show_job_note/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # ...............................................................................

  def is_job_exist(_, %{job_id: id}) do
    case Jobs.get_job(id) do
      nil -> {:error, ["job doesn't exist"]}
      %Job{} = data -> {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something went wrong."], __ENV__.line)
  end

  def is_job_exist(_, _), do: {:ok, []}

  def verify_note_type(%{is_job_exist: %{inserted_by: inserted_by}}, %{
        job_id: job_id,
        user_id: user_id,
        note_type: note_type
      }) do
    case BSP.get_business_by_job_id(job_id) do
      nil ->
        {:error, "Job does not exist"}

      bus_user_id ->
        cond do
          user_id == bus_user_id and note_type in [:bsp_internal, :bsp_general] ->
            {:ok, :bsp_can_create}

          user_id == inserted_by and note_type in [:cmr_internal] ->
            {:ok, :cmr_can_create}

          true ->
            {:error, "you cannot create note type of #{note_type |> Atom.to_string()}"}
        end
    end
  end

  def create_job_note(_, %{note_type: note_type, user_id: user_id, job_id: job_id} = params) do
    %{id: branch_id} = BSP.get_branch_by_job_id(job_id)
    note_type = note_type |> Atom.to_string()
    params = Map.merge(params, %{note_type: note_type, cmr_id: user_id, branch_id: branch_id})

    case Jobs.create_job_note(params) do
      {:ok, data} -> {:ok, data}
      {:error, %Ecto.Changeset{errors: _}} -> {:error, ["Note Altredy Added"]}
    end
  end

  def show_job_note(%{is_job_exist: %{inserted_by: inserted_by}}, %{
        current_user_id: current_user_id,
        job_id: job_id
      }) do
    employees_user_ids = Core.Employees.get_employee_by_job_id(job_id)

    cond do
      current_user_id == inserted_by ->
        {:ok,
         %{job_id: job_id, note_type: "cmr_internal"}
         |> Jobs.get_job_note_by()
         |> merge_user_short_object()}

      current_user_id in employees_user_ids ->
        {:ok,
         %{job_id: job_id, note_type: "bsp_internal"}
         |> Jobs.get_job_note_by()
         |> merge_user_short_object()}

      true ->
        {:ok, []}
    end
  end

  def show_job_note(_, %{current_user_id: current_user_id, user_id: user_id}) do
    {:ok,
     Jobs.get_cmr_job_notes(current_user_id, user_id)
     |> merge_user_short_object}
  end

  def show_job_note(_, %{current_user_id: current_user_id, branch_id: branch_id}) do
    {:ok,
     Jobs.get_bsp_job_notes(current_user_id, branch_id)
     |> merge_user_short_object}
  end

  def merge_user_short_object(notes) do
    Enum.map(notes, fn %{user_id: user_id} = note ->
      user = Accounts.get_user_small_object(user_id)
      Map.merge(note, %{user: user})
    end)
  end
end
