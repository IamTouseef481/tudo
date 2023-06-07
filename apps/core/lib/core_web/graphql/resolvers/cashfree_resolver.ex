defmodule CoreWeb.GraphQL.Resolvers.CashfreeResolver do
  use CoreWeb, :core_resolver
  alias CoreWeb.Controllers.CashfreeController

  @default_error ["unexpected error occurred"]

  def auth,
    do: {System.get_env("CASHFREE_X_CLIENT_ID"), System.get_env("CASHFREE_X_CLIENT_SECRET")}

  def create_cashfree_order_and_pay(_, %{input: input}, %{context: %{current_user: current_user}}) do
    create_cashfree_order(nil, %{input: Map.merge(input, %{with_pay: true})}, %{
      context: %{current_user: current_user}
    })
  end

  def create_cashfree_order(_, %{input: input}, %{context: %{current_user: current_user}}) do
    params =
      input
      |> add_channel_in_params()
      |> is_payment_on_behalf_cmr(current_user)

    case params do
      %{} -> create_cashfree_order(params)
      {:error, _} = error -> error
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end

  def create_cashfree_order(%{country_id: country_id, user: user} = input) do
    with %{currency_code: "INR"} <-
           Core.Regions.get_countries(country_id),
         input <-
           Map.merge(input, %{
             user_id: user.id,
             #  user: user,
             #  country_id: country_id,
             country_code: "INR",
             payment_method_id: "cashfree",
             customer_details: %{
               customer_id: to_string(user.id),
               customer_email: user.email,
               customer_phone: user.mobile |> String.replace(["(", ")", "-", " "], "")
             }
           }),
         {:ok, data} <-
           CashfreeController.create_cashfree_order(input) do
      {:ok, data}
    else
      %{currency_code: _} ->
        {:error, ["This service is available in India only"]}

      {:error, error} ->
        {:error, error}

      exception ->
        logger(__MODULE__, exception, @default_error, __ENV__.line)
    end
  end

  def add_channel_in_params(input) do
    if input[:payment_method][:emi][:card_bank_name] == :Standard_Chartered do
      {_, input} =
        get_and_update_in(
          input[:payment_method][:emi],
          &{:ok, Map.merge(&1, %{card_bank_name: "Standard Chartered"})}
        )

      input
    else
      input
    end
  end

  def is_payment_on_behalf_cmr(%{order_id: _order_id} = input, current_user),
    do: Map.merge(input, %{user: current_user, country_id: current_user.country_id})

  def is_payment_on_behalf_cmr(%{job_id: job_id} = input, %{id: current_user_id} = current_user) do
    %{inserted_by: inserted_by, employee_id: employee_id} = Core.Jobs.get_job!(job_id)
    %{user_id: bsp_user_id} = Core.Employees.get_employee!(employee_id)

    cond do
      current_user_id == inserted_by ->
        Map.merge(input, %{country_id: current_user.country_id, user: current_user})

      bsp_user_id == current_user_id ->
        user = Core.Accounts.get_user!(inserted_by)
        Map.merge(input, %{country_id: user.country_id, user: user})

      true ->
        {:error, ["This job does not belong to you."]}
    end
  end

  def create_cashfree_plan(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case CashfreeController.create_cashfree_plan(Map.merge(input, %{user_id: current_user.id})) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CashFree Subscription plan"], __ENV__.line)
  end

  def create_cashfree_subscription(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case CashfreeController.create_cashfree_subscription(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CashFree Subscription"], __ENV__.line)
  end

  def create_beneficiary(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id, user: current_user})

    case check_user_address(current_user.address) do
      :ok ->
        case CashfreeController.create_beneficiary(input) do
          {:ok, data} ->
            {:ok, data}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CashFree Beneficiary"], __ENV__.line)
  end

  def list_beneficiary(_, _, %{context: %{current_user: %{id: user_id}}}) do
    case Core.CashfreePayments.get_beneficiary_by(user_id) do
      data ->
        {:ok, data}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Something Went Wrong"], __ENV__.line)
  end

  def check_user_address(address) do
    if is_nil(address), do: {:error, "Please add your address"}, else: :ok
  end

  def delete_beneficiary(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user: current_user})

    case CashfreeController.delete_beneficiary(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CashFree Beneficiary"], __ENV__.line)
  end

  def create_cashfree_payout(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id, country_id: current_user.country_id})

    case CashfreeController.create_cashfree_payout(input) do
      {:ok, data} ->
        {:ok, data}

      {:error, error} ->
        {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to create CashFree Beneficiary"], __ENV__.line)
  end

  def update_payment_when_order_pay(_, %{input: input}, %{context: %{current_user: current_user}}) do
    case is_payment_on_behalf_cmr(input, current_user) do
      %{} = params ->
        case CashfreeController.update_payment_when_order_pay(
               Map.merge(params, %{user_id: current_user.id})
             ) do
          {:ok, data} ->
            {:ok, data}

          {:error, error} ->
            {:error, error}
        end

      {:error, _} = error ->
        error
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["Unable to get CashFree order"], __ENV__.line)
  end
end
