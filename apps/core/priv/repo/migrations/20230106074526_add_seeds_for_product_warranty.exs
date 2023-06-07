defmodule Core.Repo.Migrations.AddSeedsForProductWarranty do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @product_warranty_types "product_types"
  @product_manufacturer_names "product_manufacturers"
  @seed_product_warranty_types "20210903070503_seed_product_warranty_types"
  @seed_product_manufacturer_names "20210903070504_seed_product_manufacturer_names"

  def up do
    import_from_csv(@seed_product_warranty_types, &map_to_table(&1, @product_warranty_types))
    # reset_id_seq(@product_warranty_types)

    import_from_csv(
      @seed_product_manufacturer_names,
      &map_to_table(&1, @product_manufacturer_names)
    )

    # reset_id_seq(@product_manufacturer_names)
  end

  def down do
  end
end
