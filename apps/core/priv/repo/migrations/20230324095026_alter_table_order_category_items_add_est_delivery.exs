defmodule Core.Repo.Migrations.AlterTableOrderCategoryItemsAddEstDelivery do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :est_delivery_sec, :string
    end
  end
end
