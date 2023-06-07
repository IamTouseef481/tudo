defmodule Core.Repo.Migrations.AlterTableBranchesAndRawBusinessForFullTextSearch do
  @moduledoc false
  use Ecto.Migration
  @disable_migration_lock true
  @disable_ddl_transaction true

  def change do
    alter table(:branches) do
      remove :search_tsvector
    end

    alter table(:raw_businesses) do
      remove :search_tsvector
    end

    # ALTER TABLE branches TYPES TO ADD TS_VECTOR
    execute """
            ALTER TABLE branches
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                coalesce(name, '') || ' ' ||
                coalesce(description, '') || ' ' ||
                coalesce(phone, '') || ' ')
            ) STORED
            """,
            "ALTER TABLE branches DROP COLUMN search_tsvector"

    create index("branches", ["search_tsvector"],
             name: :branches_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )

    # ALTER TABLE raw_businesses TYPES TO ADD TS_VECTOR
    execute """
            ALTER TABLE raw_businesses
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                coalesce(name, '') || ' ' ||
                coalesce(phone, '') || ' ' ||
                coalesce(business_profile_info, '') || ' ')
            ) STORED
            """,
            "ALTER TABLE raw_businesses DROP COLUMN search_tsvector"

    create index("raw_businesses", ["search_tsvector"],
             name: :raw_businesses_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )
  end
end
