defmodule Core.Repo.Migrations.AlterTableRawBusinessesAddIndexes do
  @moduledoc false
  use Ecto.Migration

  @table :raw_businesses
  def change do
    create index(@table, [
             :business_type_id,
             :status_id,
             :location
           ])
  end
end
