defmodule Core.Jobs do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo
  alias CoreWeb.Utils.Paginator

  alias Core.Schemas.{
    Branch,
    BranchService,
    Business,
    CountryService,
    Job,
    JobCategory,
    JobHistory,
    JobRequest,
    JobStatus,
    Service,
    JobNote,
    Employee
  }

  @doc """
  Returns the list of job_categories.

  ## Examples

      iex> list_job_categories()
      [%JobCategory{}, ...]

  """
  def list_job_categories do
    Repo.all(JobCategory)
  end

  @doc """
  Gets a single job_category.

  Raises `Ecto.NoResultsError` if the Job category does not exist.

  ## Examples

      iex> get_job_category!(123)
      %JobCategory{}

      iex> get_job_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_category!(id), do: Repo.get!(JobCategory, id)
  def get_job_category(id), do: Repo.get(JobCategory, id)

  @doc """
  Creates a job_category.

  ## Examples

      iex> create_job_category(%{field: value})
      {:ok, %JobCategory{}}

      iex> create_job_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_category(attrs \\ %{}) do
    %JobCategory{}
    |> JobCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_category.

  ## Examples

      iex> update_job_category(job_category, %{field: new_value})
      {:ok, %JobCategory{}}

      iex> update_job_category(job_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_category(%JobCategory{} = job_category, attrs) do
    job_category
    |> JobCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a JobCategory.

  ## Examples

      iex> delete_job_category(job_category)
      {:ok, %JobCategory{}}

      iex> delete_job_category(job_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_category(%JobCategory{} = job_category) do
    Repo.delete(job_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_category changes.

  ## Examples

      iex> change_job_category(job_category)
      %Ecto.Changeset{source: %JobCategory{}}

  """
  def change_job_category(%JobCategory{} = job_category) do
    JobCategory.changeset(job_category, %{})
  end

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  def get_jobs_for_cmr(%{user_id: user_id, job_cmr_status_id: job_status}) do
    pagination_params = Paginator.make_pagination_params()

    from(j in Job, where: j.inserted_by == ^user_id and j.job_cmr_status_id in ^job_status)
    |> Scrivener.Paginater.paginate(pagination_params)
  end

  def get_jobs_for_cmr_with_notes(%{user_id: user_id, branch_id: branch_id}) do
    pagination_params = Paginator.make_pagination_params()

    from(j in Job,
      join: jn in JobNote,
      on: j.id == jn.job_id and jn.note_type in ["bsp_general", "cmr_internal"],
      where: j.inserted_by == ^user_id,
      where: jn.branch_id == ^branch_id,
      preload: [job_notes: jn]
    )
    |> Scrivener.Paginater.paginate(pagination_params)
  end

  def get_jobs_statuses_count_for_cmr(user_id) do
    Job
    |> where([j], j.inserted_by == ^user_id and j.job_status_id not in ["paid", "finalized"])
    |> select([j], count(j.job_cmr_status_id))
    |> Repo.one()
  end

  #  def get_jobs_for_cmr(%{user_id: user_id, job_cmr_status_id: job_status}) do
  #    from(j in Job, where: j.inserted_by == ^user_id and j.job_cmr_status_id in ^job_status)
  #    |> Repo.all()
  #  end

  def get_jobs_for_bsp(%{employee_id: employee_id, job_bsp_status_id: job_status}) do
    pagination_params = Paginator.make_pagination_params()

    from(j in Job, where: j.employee_id == ^employee_id and j.job_bsp_status_id in ^job_status)
    |> Scrivener.Paginater.paginate(pagination_params)
  end

  def get_jobs_for_bsp(%{current_user_id: current_user_id, user_id: user_id}) do
    pagination_params = Paginator.make_pagination_params()

    from(j in Job,
      join: e in Employee,
      on: e.id == j.employee_id,
      join: jn in JobNote,
      on: j.id == jn.job_id and jn.note_type in ["bsp_general", "bsp_internal"],
      select: j,
      where: j.inserted_by == ^user_id,
      where: e.user_id == ^current_user_id,
      preload: [job_notes: jn]
    )
    |> Scrivener.Paginater.paginate(pagination_params)
  end

  #  def get_jobs_for_bsp(%{employee_id: employee_id, job_bsp_status_id: job_status}) do
  #    from(j in Job,
  #      where: j.employee_id == ^employee_id and j.job_bsp_status_id in ^job_status,
  #      group_by: j.id, select: j)
  #    |> Repo.all()
  #  end

  def get_jobs_by_branch(%{branch_id: branch_id}) do
    from(j in Job,
      join: e in Core.Schemas.Employee,
      on: j.employee_id == e.id,
      where: e.branch_id == ^branch_id
    )
    |> Repo.all()
  end

  def get_single_day_branch_jobs_count(branch_id) do
    day_start = Timex.beginning_of_day(DateTime.utc_now())
    day_end = Timex.end_of_day(DateTime.utc_now())

    from(j in Job,
      join: e in Core.Schemas.Employee,
      on: j.employee_id == e.id,
      join: b in Core.Schemas.Branch,
      on: e.branch_id == b.id,
      where:
        e.branch_id == ^branch_id and j.started_working_at >= ^day_start and
          j.started_working_at <= ^day_end,
      select: count(j.id)
    )
    |> Repo.one()
  end

  def get_jobs_for_availability(%{employee_id: employee_id, inserted_by: inserted_by}) do
    from(j in Job,
      order_by: j.arrive_at,
      where:
        j.employee_id == ^employee_id and
          j.inserted_by == ^inserted_by and
          j.job_status_id in ^[
            "waiting",
            "confirmed",
            "on_board",
            "started_heading",
            "started_working"
          ]
    )
    |> Repo.all()
  end

  def get_branch_jobs_for_availability(%{branch_id: branch_id}) do
    from(j in Job,
      join: bs in BranchService,
      on: bs.id == j.branch_service_id,
      join: b in Branch,
      on: b.id == bs.branch_id,
      order_by: j.arrive_at,
      where:
        b.id == ^branch_id and
          j.job_status_id in ^[
            "waiting",
            "confirmed",
            "on_board",
            "started_heading",
            "started_working"
          ]
    )
    |> Repo.all()
  end

  #  def get_jobs_for_availability(%{employee_id: employee_id, inserted_by: inserted_by}) do
  #    Repo.all from j in Job,
  #             left_join: e in Employee, on: j.employee_id == e.id,
  #             left_join: b in Branch, on: b.id == e.branch_id,
  #             left_join: st in Setting, on: b.business_id == st.business_id,
  #             where: j.employee_id == ^employee_id
  #                    and j.inserted_by == ^inserted_by
  #                    and j.job_status_id in ^["waiting", "confirmed", "on_board", "started_heading", "started_working"]
  #             and st.slug == ^"availability",
  #             select: %{
  #               id: j.id,
  #               arrive_at: j.arrive_at,
  #               expected_work_duration: j.expected_work_duration,
  #               employee_id: j.employee_id,
  #               setting: st.fields
  #             }
  #  end

  def get_employee_jobs(employee_id) do
    from(j in Job, where: j.employee_id == ^employee_id)
    |> Repo.all()
  end

  def get_job_id(job_id) do
    from(j in Job, where: j.id == ^job_id and not is_nil(j.employee_id))
    |> Repo.one()
  end

  def get_ratings_by(%{branch_id: branch_id}) do
    from(j in Job,
      join: bs in BranchService,
      on: j.branch_service_id == bs.id,
      where: bs.branch_id == ^branch_id and not is_nil(j.cmr_to_bsp_rating),
      order_by: [desc: j.updated_at],
      limit: 25
    )
    |> Repo.all()
  end

  def get_ratings_by(%{user_id: user_id}) do
    from(j in Job,
      where: j.inserted_by == ^user_id and not is_nil(j.bsp_to_cmr_rating),
      order_by: [desc: j.updated_at],
      limit: 25
    )
    |> Repo.all()
  end

  def get_ratings_avg_by(%{branch_id: branch_id}) do
    time = Timex.shift(DateTime.utc_now(), months: -12)

    from(j in Job,
      join: bs in BranchService,
      on: j.branch_service_id == bs.id,
      where:
        bs.branch_id == ^branch_id and not is_nil(j.cmr_to_bsp_rating) and j.updated_at >= ^time,
      select: avg(j.cmr_to_bsp_rating)
    )
    |> Repo.one()
  end

  def get_ratings_avg_by(%{employee_id: employee_id}) do
    time = Timex.shift(DateTime.utc_now(), months: -12)

    from(j in Job,
      where:
        j.employee_id == ^employee_id and not is_nil(j.cmr_to_bsp_rating) and
          j.updated_at >= ^time,
      select: avg(j.cmr_to_bsp_rating)
    )
    |> Repo.one()
  end

  def get_ratings_avg_by(%{user_id: user_id}) do
    time = Timex.shift(DateTime.utc_now(), months: -12)

    from(j in Job,
      where:
        j.inserted_by == ^user_id and not is_nil(j.bsp_to_cmr_rating) and j.updated_at >= ^time,
      select: avg(j.bsp_to_cmr_rating)
    )
    |> Repo.one()
  end

  defp branch_services_base_query do
    BranchService
    |> join(:inner, [bs], b in Branch, on: b.id == bs.branch_id)
    |> join(:inner, [_, b], bus in Business, on: bus.id == b.business_id)
    |> join(:inner, [bs], cs in CountryService, on: cs.id == bs.country_service_id)
    |> join(:inner, [_, _, _, cs], s in Service, on: s.id == cs.service_id)
  end

  def get_branch_services_for_bsp(ids) when is_list(ids) do
    branch_services_base_query()
    |> where([bs], bs.id in ^ids)
    |> branch_services_select()
    |> Repo.all()
  end

  def get_branch_services_for_bsp(id) do
    branch_services_base_query()
    |> where([bs], bs.id == ^id)
    |> branch_services_select()
    |> Repo.one()
  end

  defp branch_services_select(query) do
    query
    |> select([bs, b, bus, _, s], %{
      bsp_name: bus.name,
      rating: b.rating,
      phone_number: b.phone,
      branch_service_id: bs.id,
      service_type_id: s.service_type_id,
      service_name: s.name,
      address: b.address,
      branch_location: b.location
    })
  end

  #  def get_branch_services_for_bsp(branch_service_id) when is_integer(branch_service_id) do
  #    Repo.one from bs in BranchService,
  #             join: b in Branch, on: b.id == bs.branch_id,
  #             join: bus in Business, on: bus.id == b.business_id,
  #             join: cs in CountryService, on: cs.id == bs.country_service_id,
  #             join: s in Service, on: s.id == cs.service_id,
  #             where: bs.id == ^branch_service_id,
  #             distinct: bs.id,
  #             limit: 1,
  #             select: %{bsp_name: bus.name, rating: b.rating, phone_number: b.phone, branch_service_id: bs.id,
  #                        service_type_id: s.service_type_id, service_name: s.name, address: b.address,
  #                        branch_location: b.location}
  #  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)
  def get_job(id), do: Repo.get(Job, id)

  def get_job_by_invoice(invoice_id) do
    from(j in Job,
      join: i in Core.Schemas.Invoice,
      on: i.job_id == j.id,
      where: i.id == ^invoice_id,
      distinct: j.id
    )
    |> Repo.one()
  end

  def get_job_by_cash_payment_id(payment_id) do
    from(j in Job,
      join: i in Core.Schemas.Invoice,
      on: i.job_id == j.id,
      join: cp in Core.Schemas.CashPayment,
      on: cp.invoice_id == i.id,
      where: cp.id == ^payment_id,
      distinct: j.id
    )
    |> Repo.one()
  end

  def get_job_by_cheque_payment_id(payment_id) do
    from(j in Job,
      join: i in Core.Schemas.Invoice,
      on: i.job_id == j.id,
      join: cp in Core.Schemas.ChequePayment,
      on: cp.invoice_id == i.id,
      where: cp.id == ^payment_id,
      distinct: j.id
    )
    |> Repo.one()
  end

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    attrs = fil_old_job_status_id(job, attrs)

    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  def get_empty_branch_service_ids() do
    Job
    |> where([j], fragment("? && '{}'", j.branch_service_ids))
    |> Repo.all()
  end

  defp fil_old_job_status_id(
         %{job_cmr_status_id: old_job_cmr_status},
         %{job_cmr_status_id: _} = attrs
       ) do
    Map.merge(attrs, %{old_job_status_id: old_job_cmr_status})
  end

  defp fil_old_job_status_id(_, attrs), do: attrs

  @doc """
  Deletes a Job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{source: %Job{}}

  """
  def change_job(%Job{} = job) do
    Job.changeset(job, %{})
  end

  @doc """
  Returns the list of job_statuses.

  ## Examples

      iex> list_job_statuses()
      [%JobStatus{}, ...]

  """
  def list_job_statuses do
    Repo.all(JobStatus)
  end

  @doc """
  Gets a single job_status.

  Raises `Ecto.NoResultsError` if the Job status does not exist.

  ## Examples

      iex> get_job_status!(123)
      %JobStatus{}

      iex> get_job_status!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_status!(id), do: Repo.get!(JobStatus, id)
  def get_job_status(id), do: Repo.get(JobStatus, id)

  @doc """
  Creates a job_status.

  ## Examples

      iex> create_job_status(%{field: value})
      {:ok, %JobStatus{}}

      iex> create_job_status(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_status(attrs \\ %{}) do
    %JobStatus{}
    |> JobStatus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_status.

  ## Examples

      iex> update_job_status(job_status, %{field: new_value})
      {:ok, %JobStatus{}}

      iex> update_job_status(job_status, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_status(%JobStatus{} = job_status, attrs) do
    job_status
    |> JobStatus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a JobStatus.

  ## Examples

      iex> delete_job_status(job_status)
      {:ok, %JobStatus{}}

      iex> delete_job_status(job_status)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_status(%JobStatus{} = job_status) do
    Repo.delete(job_status)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_status changes.

  ## Examples

      iex> change_job_status(job_status)
      %Ecto.Changeset{source: %JobStatus{}}

  """
  def change_job_status(%JobStatus{} = job_status) do
    JobStatus.changeset(job_status, %{})
  end

  @doc """
  Returns the list of job_history.

  ## Examples

      iex> list_job_history()
      [%JobHistory{}, ...]

  """
  def list_job_history do
    Repo.all(JobHistory)
  end

  @doc """
  Gets a single job_history.

  Raises `Ecto.NoResultsError` if the Job history does not exist.

  ## Examples

      iex> get_job_history!(123)
      %JobHistory{}

      iex> get_job_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_history!(id), do: Repo.get!(JobHistory, id)

  def get_job_history_by_job(id) do
    from(jh in JobHistory,
      where: jh.job_id == ^id,
      order_by: [desc: jh.created_at]
    )
    |> Repo.all()
  end

  @doc """
  Creates a job_history.

  ## Examples

      iex> create_job_history(%{field: value})
      {:ok, %JobHistory{}}

      iex> create_job_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_history(attrs \\ %{}) do
    %JobHistory{}
    |> JobHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_history.

  ## Examples

      iex> update_job_history(job_history, %{field: new_value})
      {:ok, %JobHistory{}}

      iex> update_job_history(job_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_history(%JobHistory{} = job_history, attrs) do
    job_history
    |> JobHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_history.

  ## Examples

      iex> delete_job_history(job_history)
      {:ok, %JobHistory{}}

      iex> delete_job_history(job_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_history(%JobHistory{} = job_history) do
    Repo.delete(job_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_history changes.

  ## Examples

      iex> change_job_history(job_history)
      %Ecto.Changeset{source: %JobHistory{}}

  """
  def change_job_history(%JobHistory{} = job_history) do
    JobHistory.changeset(job_history, %{})
  end

  @doc """
  Returns the list of job_requests.

  ## Examples

      iex> list_job_requests()
      [%JobRequest{}, ...]

  """
  def list_job_requests do
    Repo.all(JobRequest)
  end

  @doc """
  Gets a single job_request.

  Raises `Ecto.NoResultsError` if the Job request does not exist.

  ## Examples

      iex> get_job_request!(123)
      %JobRequest{}

      iex> get_job_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job_request!(id), do: Repo.get(JobRequest, id)

  def get_job_request_by(lead_id, job_status_id) do
    from(jr in JobRequest,
      where: jr.lead_id == ^lead_id,
      where: jr.job_status_id == ^job_status_id
    )
    |> Repo.all()
  end

  def get_job_request_by(%{employee_id: employee_id, job_status_id: job_status_id}) do
    from(jr in JobRequest,
      where: jr.employee_id == ^employee_id,
      where: jr.job_status_id == ^job_status_id
    )
    |> Repo.all()
  end

  def get_job_request_by(%{employee_id: employee_id}) do
    from(jr in JobRequest,
      where: jr.employee_id == ^employee_id
    )
    |> Repo.all()
  end

  @doc """
  Creates a job_request.

  ## Examples

      iex> create_job_request(%{field: value})
      {:ok, %JobRequest{}}

      iex> create_job_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job_request(attrs \\ %{}) do
    %JobRequest{}
    |> JobRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job_request.

  ## Examples

      iex> update_job_request(job_request, %{field: new_value})
      {:ok, %JobRequest{}}

      iex> update_job_request(job_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job_request(%JobRequest{} = job_request, attrs) do
    job_request
    |> JobRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job_request.

  ## Examples

      iex> delete_job_request(job_request)
      {:ok, %JobRequest{}}

      iex> delete_job_request(job_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job_request(%JobRequest{} = job_request) do
    Repo.delete(job_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job_request changes.

  ## Examples

      iex> change_job_request(job_request)
      %Ecto.Changeset{source: %JobRequest{}}

  """
  def change_job_request(%JobRequest{} = job_request) do
    JobRequest.changeset(job_request, %{})
  end

  def create_job_note(params) do
    %JobNote{}
    |> JobNote.changeset(params)
    |> Repo.insert()
  end

  def get_job_note_by(%{job_id: job_id, note_type: note_type}) do
    JobNote
    |> where([jn], jn.job_id == ^job_id and jn.note_type in ["bsp_general", ^note_type])
    |> Repo.all()
  end

  def get_cmr_job_notes(current_user_id, user_id) do
    from(j in Job,
      join: e in Employee,
      on: e.id == j.employee_id,
      join: jn in JobNote,
      on: j.id == jn.job_id,
      select: jn,
      where: e.user_id == ^current_user_id,
      where: j.inserted_by == ^user_id and jn.note_type in ["bsp_general", "bsp_internal"]
    )
    |> Repo.all()
  end

  def get_bsp_job_notes(current_user_id, branch_id) do
    from(j in Job,
      join: jn in JobNote,
      on: jn.branch_id == ^branch_id,
      select: jn,
      where: j.inserted_by == ^current_user_id and jn.note_type in ["bsp_general", "cmr_internal"]
    )
    |> Repo.all()
  end
end
