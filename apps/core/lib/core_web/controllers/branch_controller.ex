defmodule CoreWeb.Controllers.BranchController do
  @moduledoc false
  use CoreWeb, :controller

  alias Core.{BSP, Accounts}
  alias CoreWeb.Helpers.BranchHelper
  alias Core.Schemas.User

  def create_branch(input) do
    with {:ok, _last, all} <- BranchHelper.create_branch(input),
         %{branch: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def update_branch(%{id: _id} = input) do
    with {:ok, _last, all} <- BranchHelper.update_branch(input),
         %{branch: data} <- all do
      {:ok, data}
    else
      {:error, error} -> {:error, error}
      all -> {:error, all}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, :info, __ENV__.line)
      exception
  end

  def delete_branch(%{id: _id} = input) do
    case BSP.get_branch_by_user(input) do
      nil ->
        {:error, ["This business doesn't belongs to you"]}

      %{business_id: bus_id} = branch ->
        updated_branch = BSP.update_branch(branch, %{status_id: "deleted"})

        with [] <- BSP.get_branch_by_business(bus_id),
             %User{} = user <- Accounts.get_user!(input[:user_id]),
             %User{} <- Accounts.update_user(user, %{is_bsp: false}) do
          :ok
        end

        updated_branch
    end
  rescue
    exception ->
      logger(
        __MODULE__,
        exception,
        ["Something went wrong, can't delete Branch. Services are associated with the Branch"],
        __ENV__.line
      )
  end
end
