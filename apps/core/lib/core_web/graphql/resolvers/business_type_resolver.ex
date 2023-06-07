defmodule CoreWeb.GraphQL.Resolvers.BusinessTypeResolver do
  @moduledoc false
  alias Core.BSP
  alias CoreWeb.Controllers.BusinessTypeController

  def list_business_types(_, _, _) do
    {:ok, BSP.list_business_types()}
  end

  def create_business_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case BusinessTypeController.create_business_type(input) do
      {:ok, data} ->
        #        Absinthe.Subscription.publish(CoreWeb.Endpoint, user, create_user: true)
        {:ok, data}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_business_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case BusinessTypeController.update_business_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end

  def get_business_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case BusinessTypeController.get_business_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_business_type(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case BusinessTypeController.delete_business_type(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
      _ -> {:error, ["unexpected error occurred!"]}
    end
  end
end
