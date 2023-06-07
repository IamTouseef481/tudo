defmodule Core.Repo.Migrations.CreatePaymentMethods do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:payment_methods, primary_key: false) do
      add :id, :string, primary_key: true
      add :description, :string
    end
  end
end
