defmodule Stitch.Repo.Migrations.AddCardholderNameToPaymentMethod do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:payment_methods) do
      add :cardholder_name, :string
    end
  end
end
