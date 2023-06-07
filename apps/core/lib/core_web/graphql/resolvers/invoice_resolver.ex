defmodule CoreWeb.GraphQL.Resolvers.InvoiceResolver do
  @moduledoc false
  use CoreWeb.GraphQL, :resolver
  alias Core.Payments.TipsDonationsBspAmountsCalculator, as: AMC
  alias Core.{BSP, Employees, Invoices, Jobs, Regions, Services}
  alias CoreWeb.Controllers.InvoiceController

  @common_error ["Unexpected error occurred, try again!"]
  @invoice_error ["unable to generate invoice"]

  def list_invoices(_, _, _) do
    {:ok, Invoices.list_invoices()}
  end

  def employee_verified?(%{job_id: job_id, user_id: user_id}) do
    with %{employee_id: employee_id} <- Jobs.get_job(job_id),
         employees <- Employees.get_employees_by_user_id(user_id) do
      employee_ids = Enum.map(employees, & &1.id)
      if employee_id in employee_ids, do: true, else: false
    else
      _ -> false
    end
  end

  def valid_for_get_invoice?(%{user_id: user_id, employee_id: employee_id, cmr_id: cmr_id}) do
    with employees <- Employees.get_employees_by_user_id(user_id) do
      employee_ids = Enum.map(employees, & &1.id)
      if employee_id in employee_ids or user_id == cmr_id, do: true, else: false
    end
  end

  def get_invoice_by_job(_, %{input: %{job_id: _job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    get_invoice_by_job(input, current_user.id)
  end

  def get_invoice_by_job(input, user_id) do
    with {:ok,
          %{
            employee_id: employee_id,
            inserted_by: cmr_id,
            cost: unit_price,
            branch_service_id: _,
            branch_service_ids: _
          } = job} <- get_job(input.job_id),
         {:ok, %{id: business_id}} <- get_business_by_employee_id_for_invoices(employee_id),
         {:ok, %{id: branch_id}} <- get_branch_by_employee_id_for_invoices(employee_id),
         {:ok, data} <- fetch_branch_service_data(job) do
      unit_price = if is_float(unit_price), do: Float.round(unit_price, 2), else: unit_price

      input =
        Map.merge(input, %{
          user_id: user_id,
          cmr_id: cmr_id,
          unit_price: unit_price,
          job_id: input.job_id,
          discountable_price: unit_price,
          business_id: business_id,
          branch_id: branch_id,
          employee_id: employee_id,
          job_status_id: job.job_status_id
        })

      input = add_service_data(input, data)

      case InvoiceController.get_invoice_by_job(input) do
        {:ok, data} -> {:ok, data}
        {:error, changeset} -> {:error, changeset}
        _ -> {:error, @common_error}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, @common_error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to fetch Invoice"], __ENV__.line)
  end

  @doc """
  fetch_branch_service_data/1
  checks if a job has single or multiple branch_service_ids,
  and then returns one or more records of service type.
  """
  def fetch_branch_service_data(job) do
    if is_nil(job.branch_service_ids) do
      get_service_by_branch_service(job.branch_service_id)
    else
      list_services_by_branch_services(job.branch_service_ids)
    end
  end

  @doc """
    add_service_data/2
    adds the service_id and service_name to the user input.
    This clause is for multiple service_ids and service_names

  add_service_data/2
    When the job has a single branch_service_id, only one service_id
    and one service_name will be fetched against it and will be merged with the user input data.
  """
  def add_service_data(input, data) when is_list(data) do
    {service_ids, service_names} =
      Enum.map_reduce(data, "", fn %{id: service_id, name: service_name}, acc ->
        acc =
          if is_nil(service_name),
            do: acc,
            else: service_name <> ", " <> acc

        {service_id, acc}
      end)

    Map.merge(input, %{service_ids: service_ids, service_names: service_names})
  end

  def add_service_data(input, %{id: service_id, name: service_name}) do
    Map.merge(input, %{service_id: service_id, name: service_name})
  end

  def update_invoice(_, %{input: %{job_id: job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok,
          %{
            employee_id: employee_id,
            inserted_by: cmr_id,
            cost: unit_price
          } = job} <-
           get_job(job_id),
         {:ok, %{id: business_id}} <- get_business_by_employee_id_for_invoices(employee_id),
         {:ok, %{id: branch_id}} <- get_branch_by_employee_id_for_invoices(employee_id),
         {:ok, branch_service_data} <-
           fetch_branch_service_data(job) do
      unit_price = if is_float(unit_price), do: Float.round(unit_price, 2), else: unit_price
      service = filter_required_data(branch_service_data)

      input =
        Map.merge(input, %{
          user_id: current_user.id,
          cmr_id: cmr_id,
          job_id: job_id,
          unit_price: unit_price,
          business_id: business_id,
          branch_id: branch_id,
          service_id: service.id,
          service_name: service.name,
          employee_id: employee_id
        })

      if employee_verified?(input) do
        case InvoiceController.update_invoice(input) do
          {:ok, invoice} -> {:ok, invoice}
          {:error, error} -> {:error, error}
        end
      else
        {:error, ["you are not permitted!"]}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to update invoice"], __ENV__.line)
  end

  def filter_required_data(branch_serivce) when is_list(branch_serivce) do
    %{
      id: Enum.map(branch_serivce, & &1.id),
      name: Enum.map(branch_serivce, & &1.name)
    }
  end

  def filter_required_data(branch_serivce),
    do: %{id: branch_serivce.id, name: branch_serivce.name}

  def generate_invoice(_, %{input: %{job_id: job_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, %{employee_id: employee_id}} <- get_job(job_id),
         {:ok, %{id: business_id}} <- get_business_by_employee_id_for_invoices(employee_id),
         {:ok, %{id: branch_id}} <- get_branch_by_employee_id_for_invoices(employee_id),
         {:ok, _invoice} <- check_adjust(job_id, business_id),
         {:ok, _invoice} <- check_business(input) do
      input =
        Map.merge(input, %{
          user_id: current_user.id,
          business_id: business_id,
          adjust: false,
          branch_id: branch_id
        })

      if employee_verified?(input) do
        case InvoiceController.generate_invoice(input) do
          {:ok, invoice} -> {:ok, add_insurance_and_booking_percentage(invoice)}
          {:error, error} -> {:error, error}
          _ -> {:error, @common_error}
        end
      else
        {:error, ["you are not permitted!"]}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, @common_error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @invoice_error, __ENV__.line)
  end

  def generate_invoice(_, %{input: %{id: invoice_id} = input}, %{
        context: %{current_user: current_user}
      }) do
    with {:ok, %{job_id: job_id}} <- get_invoice(invoice_id),
         {:ok, %{employee_id: employee_id}} <- get_job(job_id),
         {:ok, %{id: business_id}} <- get_business_by_employee_id_for_invoices(employee_id),
         {:ok, %{id: branch_id}} <- get_branch_by_employee_id_for_invoices(employee_id),
         {:ok, _invoice} <- check_adjust(job_id, business_id),
         {:ok, _invoice} <- check_business(input) do
      input =
        Map.merge(input, %{
          user_id: current_user.id,
          business_id: business_id,
          job_id: job_id,
          branch_id: branch_id,
          adjust: false
        })

      if employee_verified?(input) do
        case InvoiceController.generate_invoice(input) do
          {:ok, invoice} -> {:ok, add_insurance_and_booking_percentage(invoice)}
          {:error, error} -> {:error, error}
          _ -> {:error, @common_error}
        end
      else
        {:error, ["you are not permitted!"]}
      end
    else
      {:error, error} -> {:error, error}
      _ -> {:error, @common_error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @invoice_error, __ENV__.line)
  end

  def generate_invoice(_, %{input: _input}, _) do
    {:error, ["ID or Job_id missing in parameters!"]}
  end

  defp get_invoice(id) do
    case Invoices.get_invoice(id) do
      nil -> {:error, ["Invoice doesn't exist!"]}
      %{} = invoice -> {:ok, invoice}
    end
  end

  def get_job(id) do
    case Jobs.get_job(id) do
      nil -> {:error, ["job doesn't exist"]}
      %{} = job -> {:ok, job}
    end
  end

  defp check_business(%{business_id: business_id}) do
    case BSP.get_business(business_id) do
      nil -> {:error, ["business doesn't exist!"]}
      %{} = bus -> {:ok, bus}
    end
  end

  defp check_business(_params) do
    {:ok, ["valid"]}
  end

  defp check_adjust(job_id, business_id) do
    case Invoices.get_invoice_by_job(%{job_id: job_id, business_id: business_id}) do
      [] ->
        {:error, ["Invoice doesn't exist!"]}

      [invoice] ->
        if invoice.adjust do
          {:ok, invoice}
        else
          {:error, ["Invoice locked, you can't update this Invoice!"]}
        end

      _ ->
        {:error, ["error while getting invoice by job"]}
    end
  end

  defp get_business_by_employee_id_for_invoices(employee_id) do
    case BSP.get_business_by_employee_id(employee_id) do
      nil -> {:error, ["business doesn't exist!"]}
      %{} = business -> {:ok, business}
    end
  end

  defp get_branch_by_employee_id_for_invoices(employee_id) do
    case BSP.get_branch_by_employee_id(employee_id) do
      nil -> {:error, ["Business Branch doesn't exist!"]}
      %{} = branch -> {:ok, branch}
    end
  end

  def list_services_by_branch_services(branch_service_ids) do
    case Services.list_services_by_branch_service(branch_service_ids) do
      [] -> {:error, ["Business Branches don't exist!"]}
      services -> {:ok, services}
    end
  end

  defp get_service_by_branch_service(branch_service_id) do
    case Services.get_service_by_branch_service(branch_service_id) do
      nil -> {:error, ["branch service doesn't exist!"]}
      %{} = service -> {:ok, service}
    end
  end

  def adjust_invoice(_, %{input: %{id: _id} = input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case InvoiceController.adjust_invoice(input) do
      {:ok, invoice} -> {:ok, add_insurance_and_booking_percentage(invoice)}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unexpected error occurred, try again!"]}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unable to adjust invoice"], __ENV__.line)
  end

  def add_insurance_and_booking_percentage(invoice) do
    country_id =
      if Map.get(invoice, :country_id) do
        invoice.country_id
      else
        case Regions.get_country_by_job(invoice.job_id) do
          %{id: id} -> id
          _ -> 1
        end
      end

    booking_percentage = AMC.getting_tudo_charges("booking_fee", country_id)
    insurance_percentage = AMC.getting_tudo_charges("insurance_fee", country_id)

    Map.merge(invoice, %{
      insurance_percentage: insurance_percentage,
      booking_percentage: booking_percentage
    })
  end

  #  def create_invoice(_, %{input: input}, %{context: %{current_user: current_user}}) do
  ##    input = Map.merge(input, %{user_id: current_user.id})
  #    case InvoiceController.create_invoice(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end

  #  def update_invoice(_, %{input: input}, %{context: %{current_user: current_user}}) do
  #    input = Map.merge(input, %{user_id: current_user.id})
  #    case InvoiceController.update_invoice(input) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end

  #  def get_invoice(_, %{input: %{id: id} = input}, %{context: %{current_user: current_user}}) do
  ##    input = Map.merge(input, %{user_id: current_user.id})
  #    case InvoiceController.get_invoice(id) do
  #      {:ok, data} -> {:ok, data}
  #      {:error, changeset} -> {:error, changeset}
  #      _ -> {:error, ["Unexpected error occurred, try again!"]}
  #    end
  #  end
end
