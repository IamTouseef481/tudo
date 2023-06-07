defmodule Core.CashPayments do
  @moduledoc """
  The CashPayments context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{CashPayment, ChequePayment}

  @doc """
  Returns the list of cash_payments.

  ## Examples

      iex> list_cash_payments()
      [%CashPayment{}, ...]

  """
  def list_cash_payments do
    Repo.all(CashPayment)
  end

  @doc """
  Gets a single cash_payment.

  Raises `Ecto.NoResultsError` if the Cash payment does not exist.

  ## Examples

      iex> get_cash_payment!(123)
      %CashPayment{}

      iex> get_cash_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cash_payment!(id), do: Repo.get!(CashPayment, id)
  def get_cash_payment(id), do: Repo.get(CashPayment, id)

  def get_cash_payment_by_invoice(invoice_id) do
    from(cp in CashPayment, where: cp.invoice_id == ^invoice_id)
    |> Repo.all()
  end

  @doc """
  Creates a cash_payment.

  ## Examples

      iex> create_cash_payment(%{field: value})
      {:ok, %CashPayment{}}

      iex> create_cash_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cash_payment(attrs \\ %{}) do
    %CashPayment{}
    |> CashPayment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cash_payment.

  ## Examples

      iex> update_cash_payment(cash_payment, %{field: new_value})
      {:ok, %CashPayment{}}

      iex> update_cash_payment(cash_payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cash_payment(%CashPayment{} = cash_payment, attrs) do
    cash_payment
    |> CashPayment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cash_payment.

  ## Examples

      iex> delete_cash_payment(cash_payment)
      {:ok, %CashPayment{}}

      iex> delete_cash_payment(cash_payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cash_payment(%CashPayment{} = cash_payment) do
    Repo.delete(cash_payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cash_payment changes.

  ## Examples

      iex> change_cash_payment(cash_payment)
      %Ecto.Changeset{source: %CashPayment{}}

  """
  def change_cash_payment(%CashPayment{} = cash_payment) do
    CashPayment.changeset(cash_payment, %{})
  end

  @doc """
  Returns the list of cheque_payments.

  ## Examples

      iex> list_cheque_payments()
      [%ChequePayment{}, ...]

  """
  def list_cheque_payments do
    Repo.all(ChequePayment)
  end

  @doc """
  Gets a single cheque_payment.

  Raises `Ecto.NoResultsError` if the Cheque payment does not exist.

  ## Examples

      iex> get_cheque_payment!(123)
      %ChequePayment{}

      iex> get_cheque_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cheque_payment!(id), do: Repo.get!(ChequePayment, id)
  def get_cheque_payment(id), do: Repo.get(ChequePayment, id)

  def get_cheque_payment_by_invoice(invoice_id) do
    from(cp in ChequePayment, where: cp.invoice_id == ^invoice_id)
    |> Repo.all()
  end

  @doc """
  Creates a cheque_payment.

  ## Examples

      iex> create_cheque_payment(%{field: value})
      {:ok, %ChequePayment{}}

      iex> create_cheque_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cheque_payment(attrs \\ %{}) do
    %ChequePayment{}
    |> ChequePayment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cheque_payment.

  ## Examples

      iex> update_cheque_payment(cheque_payment, %{field: new_value})
      {:ok, %ChequePayment{}}

      iex> update_cheque_payment(cheque_payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cheque_payment(%ChequePayment{} = cheque_payment, attrs) do
    cheque_payment
    |> ChequePayment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cheque_payment.

  ## Examples

      iex> delete_cheque_payment(cheque_payment)
      {:ok, %ChequePayment{}}

      iex> delete_cheque_payment(cheque_payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cheque_payment(%ChequePayment{} = cheque_payment) do
    Repo.delete(cheque_payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cheque_payment changes.

  ## Examples

      iex> change_cheque_payment(cheque_payment)
      %Ecto.Changeset{source: %ChequePayment{}}

  """
  def change_cheque_payment(%ChequePayment{} = cheque_payment) do
    ChequePayment.changeset(cheque_payment, %{})
  end
end
