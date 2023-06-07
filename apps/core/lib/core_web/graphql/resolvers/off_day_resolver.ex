defmodule CoreWeb.GraphQL.Resolvers.OffDayResolver do
  @moduledoc false
  alias Core.OffDays

  def holidays_by(_, %{input: input}, _) do
    {:ok, OffDays.get_holiday_by(input)}
  end

  def create_holidays(_, %{input: input}, _) do
    case CoreWeb.Controllers.OffDayController.create_holidays(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_holidays(_, %{input: input}, _) do
    case CoreWeb.Controllers.OffDayController.update_holidays(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_holidays(_, %{input: input}, _) do
    case CoreWeb.Controllers.OffDayController.delete_holidays(input) do
      {:ok, data} -> {:ok, data}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
