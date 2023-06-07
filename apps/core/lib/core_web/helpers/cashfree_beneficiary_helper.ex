defmodule CoreWeb.Helpers.CashfreeBeneficiaryHelper do
  #   Core.PaypalPayments.Sages.Seller
  @moduledoc false

  use CoreWeb, :core_helper

  alias Core.CashfreePayments
  alias CoreWeb.Controllers.CashfreeController
  alias CoreWeb.Utils.{CommonFunctions}

  def create_beneficiary(params) do
    new()
    |> run(:verify_user, &customer_validation/2, &abort/3)
    |> run(:cashfree_beneficiary, &create_beneficiary/2, &abort/3)
    |> run(:local_cashfree_beneficiary, &create_local_beneficiary/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  def delete_beneficiary(params) do
    new()
    |> run(:verify_user, &customer_validation/2, &abort/3)
    |> run(:beneficiary, &get_beneficiary/2, &abort/3)
    |> run(:local_beneficiary, &delete_local_beneficiary/2, &abort/3)
    |> transaction(Core.Repo, params)
  end

  # --------------------create_beneficiary---------------------------

  defp customer_validation(_, %{user: user, password: password}) do
    case Argon2.verify_pass(password, user.password_hash) do
      true -> {:ok, user}
      _ -> {:error, ["Invalid user password"]}
    end
  end

  defp customer_validation(_, %{user: user}), do: {:ok, user}

  defp create_beneficiary(_, %{user: user} = params) do
    name = CommonFunctions.make_full_name_from_profile(user.profile)

    case CashfreeController.get_bearer_token_for_payout_requests() do
      {:error, error} ->
        {:error, error}

      {:ok, token} ->
        url = System.get_env("CASHFREE_BENEFICIARY_URL")

        headers = [
          {"Accept", "application/json"},
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer " <> token}
        ]

        input = %{
          "beneId" =>
            (user.id |> to_string) <> "_" <> (System.os_time(:microsecond) |> to_string) <> "_ben",
          "name" => name,
          "email" => user.email,
          "phone" => params.phone,
          "address1" => user.address
        }

        input = make_params(params, input)

        case CoreWeb.Utils.HttpRequest.post(url, input, headers, hackney: []) do
          {:ok, _message} -> {:ok, Map.merge(input, %{"beneId" => input["beneId"]})}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp create_beneficiary(_, _), do: {:ok, "not created"}

  defp create_local_beneficiary(
         %{cashfree_beneficiary: %{"beneId" => beneficiary_id} = cashfree_beneficiary_params},
         params
       ) do
    case CashfreePayments.create_cashfree_beneficiary(
           Map.merge(params, %{
             user_id: params.user_id,
             beneficiary_id: beneficiary_id,
             email: params.user.email,
             default: Map.get(params, :default) || false,
             transfer_mode: add_tranfer_mode(cashfree_beneficiary_params)
           })
         ) do
      {:ok, beneficiary} -> {:ok, beneficiary}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unable to create local CashFree beneficiary"]}
    end
  end

  defp create_local_beneficiary(_, _), do: {:error, %{message: "Something Went Wrong"}}

  def add_tranfer_mode(params) do
    Enum.reduce(params, [], fn
      {"bankAccount", _v}, acc -> acc ++ ["banktransfer"]
      {"phone", _v}, acc -> acc ++ ["paytm"]
      {"vpa", _v}, acc -> acc ++ ["upi"]
      _, acc -> acc
    end)
  end

  def make_params(params, input) do
    Enum.reduce(params, %{}, fn
      {:bank_account, v}, acc -> Map.put(acc, "bankAccount", v)
      {:vpa, v}, acc -> Map.put(acc, "vpa", v)
      {:ifsc, v}, acc -> Map.put(acc, "ifsc", v)
      {:field, v}, acc -> Map.put(acc, "field", v)
      {:pincode, v}, acc -> Map.put(acc, "pincode", v)
      {:state, v}, acc -> Map.put(acc, "state", v)
      _, acc -> acc
    end)
    |> Map.merge(input)
  end

  # --------------------remove_beneficiary---------------------------
  defp get_beneficiary(_, %{bene_id: bene_id}) do
    case CashfreePayments.get_cashfree_beneficiary(bene_id) do
      nil -> {:error, ["You do not have CashFree beneficiary"]}
      beneficiary -> {:ok, beneficiary}
    end
  end

  defp delete_local_beneficiary(%{beneficiary: beneficiary}, _) do
    case CashfreePayments.delete_cashfree_beneficiary(beneficiary) do
      {:ok, beneficiary} -> {:ok, beneficiary}
      {:error, error} -> {:error, error}
      _ -> {:error, ["Unable to delete local CashFree beneficiary"]}
    end
  end
end
