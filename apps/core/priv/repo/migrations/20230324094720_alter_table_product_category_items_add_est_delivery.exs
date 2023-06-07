defmodule Core.Repo.Migrations.AlterTableProductCategoryItemsAddEstDelivery do
  use Ecto.Migration

  def change do
    alter table(:product_category_items) do
      add :est_delivery_sec, :string
    end

    execute """
    UPDATE product_category_items
    SET est_delivery_sec='3600' WHERE id='menu_item';
    """

    execute """
    UPDATE product_category_items
    SET est_delivery_sec='864000' WHERE id='product';
    """
  end
end
