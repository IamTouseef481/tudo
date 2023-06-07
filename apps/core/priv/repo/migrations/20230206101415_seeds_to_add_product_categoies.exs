defmodule Core.Repo.Migrations.SeedsToAddProductCategories do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "product_category_items"
  @seeder "20230118135136_seed_product_category_items"
  @table_product_categories "product_categories"
  @seeder_product_categories "20230118135137_seed_product_categories"
  def change do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    import_from_csv(@seeder_product_categories, &map_to_table(&1, @table_product_categories))
  end
end
