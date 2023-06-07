defmodule Core.Invoices do
  @moduledoc """
  The Invoices context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{Invoice, InvoiceHistory, Countries, CountryService, BranchService, Job}

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)
  def get_invoice(id), do: Repo.get(Invoice, id)

  def get_invoice_by_job(%{job_id: job_id, business_id: business_id}) do
    from(i in Invoice, where: i.job_id == ^job_id and i.business_id == ^business_id)
    |> Repo.all()
  end

  def get_invoice_by_job_id(job_id) do
    from(i in Invoice, where: i.job_id == ^job_id)
    |> Repo.all()
  end

  def check_country_service_to_add_tax(invoice_id) do
    from(i in Invoice,
      join: j in Job,
      on: j.id == i.job_id,
      join: bs in BranchService,
      on: j.branch_service_id == bs.id or bs.id in j.branch_service_ids,
      join: cs in CountryService,
      on: bs.country_service_id == cs.id,
      join: c in Countries,
      on: cs.country_id == c.id,
      where: i.id == ^invoice_id,
      select: c.id
    )
    |> Repo.all()
  end

  def get_country_id_by(cs_id) do
    from(i in CountryService,
      where: i.id in ^cs_id,
      select: i.country_id
    )
    |> Repo.all()
  end

  def get_invoice_and_job(invoice_id) do
    from(i in Invoice,
      join: j in Core.Schemas.Job,
      on: j.id == i.job_id,
      where: i.id == ^invoice_id,
      select: %{invoice: i, job: j}
    )
    |> Repo.one()
  end

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{source: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice) do
    Invoice.changeset(invoice, %{})
  end

  @doc """
  Returns the list of invoice_history.

  ## Examples

      iex> list_invoice_history()
      [%InvoiceHistory{}, ...]

  """
  def list_invoice_history do
    Repo.all(InvoiceHistory)
  end

  @doc """
  Gets a single invoice_history.

  Raises `Ecto.NoResultsError` if the Invoice history does not exist.

  ## Examples

      iex> get_invoice_history!(123)
      %InvoiceHistory{}

      iex> get_invoice_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice_history!(id), do: Repo.get!(InvoiceHistory, id)
  def get_invoice_history(id), do: Repo.get(InvoiceHistory, id)

  @doc """
  Creates a invoice_history.

  ## Examples

      iex> create_invoice_history(%{field: value})
      {:ok, %InvoiceHistory{}}

      iex> create_invoice_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice_history(attrs \\ %{}) do
    %InvoiceHistory{}
    |> InvoiceHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invoice_history.

  ## Examples

      iex> update_invoice_history(invoice_history, %{field: new_value})
      {:ok, %InvoiceHistory{}}

      iex> update_invoice_history(invoice_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice_history(%InvoiceHistory{} = invoice_history, attrs) do
    invoice_history
    |> InvoiceHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invoice_history.

  ## Examples

      iex> delete_invoice_history(invoice_history)
      {:ok, %InvoiceHistory{}}

      iex> delete_invoice_history(invoice_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice_history(%InvoiceHistory{} = invoice_history) do
    Repo.delete(invoice_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice_history changes.

  ## Examples

      iex> change_invoice_history(invoice_history)
      %Ecto.Changeset{source: %InvoiceHistory{}}

  """
  def change_invoice_history(%InvoiceHistory{} = invoice_history) do
    InvoiceHistory.changeset(invoice_history, %{})
  end
end
