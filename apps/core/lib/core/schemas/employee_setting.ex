defmodule Core.Schemas.EmployeeSetting do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_settings" do
    field :experience, :boolean, default: false
    field :family, :boolean, default: false
    field :insurance, :boolean, default: false
    field :qualification, :boolean, default: false
    field :vehicle, :boolean, default: false
    field :wallet, :boolean, default: false
    belongs_to :employee, Core.Schemas.Employee

    timestamps()
  end

  @doc false
  def changeset(employee_setting, attrs) do
    employee_setting
    |> cast(attrs, [
      :employee_id,
      :wallet,
      :qualification,
      :experience,
      :insurance,
      :vehicle,
      :family
    ])
    |> validate_required([
      :employee_id,
      :wallet,
      :qualification,
      :experience,
      :insurance,
      :vehicle,
      :family
    ])
  end
end
