defmodule CoreWeb.GraphQL.Resolvers.ScheduleResolver do
  @moduledoc false
  alias Core.Schedules
  alias CoreWeb.Controllers.UserScheduleController

  def list_user_schedules(_, _, _) do
    {:ok, Schedules.list_user_schedules()}
  end

  def get_user_schedule(_, %{input: %{user_id: user_id}}, _) do
    {:ok, Schedules.get_user_schedule(user_id)}
  end

  def get_user_schedule(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserScheduleController.get_user_schedule(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_user_schedule(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserScheduleController.create_user_schedule(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_user_schedule(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserScheduleController.update_user_schedule(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_user_schedule(_, %{input: input}, %{context: %{current_user: current_user}}) do
    input = Map.merge(input, %{user_id: current_user.id})

    case UserScheduleController.delete_user_schedule(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
