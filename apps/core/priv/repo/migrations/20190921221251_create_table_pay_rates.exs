defmodule Core.Repo.Migrations.CreateTablePayRates do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:pay_rates, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :details, :map

      timestamps()
    end
  end
end
