defmodule Core.Repo.Migrations.CreateSeedLicenceIssuingAuthorities do
  @moduledoc false
  use CoreWeb.Helpers.SeedHelper

  @table "licence_issuing_authorities"
  @seeder "20190826065731_seed_licence_issuing_authorities"

  def up do
    import_from_csv(@seeder, &map_to_table(&1, @table))
    reset_id_seq(@table)
  end

  def down do
  end
end
