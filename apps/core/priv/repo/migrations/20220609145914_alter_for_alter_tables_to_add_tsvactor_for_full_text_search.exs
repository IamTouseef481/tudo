defmodule Core.Repo.Migrations.AlterForAlterTablesToAddTsvactorForFullTextSearch do
  @moduledoc false
  use Ecto.Migration
  @disable_migration_lock true
  @disable_ddl_transaction true

  def change do
    alter table(:branches) do
      remove :search_tsvector
    end

    alter table(:service_groups) do
      remove :search_tsvector
    end

    alter table(:service_types) do
      remove :search_tsvector
    end

    alter table(:services) do
      remove :search_tsvector
    end

    alter table(:raw_businesses) do
      remove :search_tsvector
    end

    execute """
            ALTER TABLE branches
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                coalesce(name, '') || ' ' ||
                coalesce(description, '') || ' ')
            ) STORED
            """,
            "ALTER TABLE branches DROP COLUMN search_tsvector"

    create index("branches", ["search_tsvector"],
             name: :branches_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )

    # ALTER TABLE SERVICE GROUPS TO ADD TS_VECTOR
    execute """
            ALTER TABLE service_groups
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english', coalesce(name, ''))
            ) STORED
            """,
            "ALTER TABLE service_groups DROP COLUMN search_tsvector"

    create index("service_groups", ["search_tsvector"],
             name: :service_groups_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )

    # ALTER TABLE SERVICE TYPES TO ADD TS_VECTOR
    execute """
            ALTER TABLE service_types
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english', coalesce(id, '') || ' ' || coalesce(description, ''))
            ) STORED
            """,
            "ALTER TABLE service_types DROP COLUMN search_tsvector"

    create index("service_types", ["search_tsvector"],
             name: :service_types_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )

    # ALTER TABLE SERVICES TO ADD TS_VECTOR
    execute """
            ALTER TABLE services
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english', coalesce(name, ''))
            ) STORED
            """,
            "ALTER TABLE services DROP COLUMN search_tsvector"

    create index("services", ["search_tsvector"],
             name: :services_search_tsvector_index,
             using: "GIN",
             concurrently: true
           )

    # ALTER TABLE SERVICE TYPES TO ADD TS_VECTOR
    execute """
            ALTER TABLE raw_businesses
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                coalesce(name, '') || ' ' ||
                coalesce(description, '') || ' ')
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
