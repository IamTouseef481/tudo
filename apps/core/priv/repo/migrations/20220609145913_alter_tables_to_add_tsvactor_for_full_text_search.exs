defmodule Core.Repo.Migrations.AlterTablesToAddTsvactorForFullTextSearch do
  @moduledoc false
  use Ecto.Migration
  @disable_migration_lock true
  @disable_ddl_transaction true

  def change do
    # ALTER TABLE BRANCHES TO ADD TS_VECTOR
    execute """
            ALTER TABLE branches
            ADD COLUMN search_tsvector tsvector
            GENERATED ALWAYS AS (
              to_tsvector('english',
                coalesce(name, '') || ' ' ||
                coalesce(description, '') || ' ' ||
                coalesce(address ->> 'city', '') || ' ' ||
                coalesce(address ->> 'address', '') || ' ' ||
                coalesce(address ->> 'zip_code', ''))
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
                coalesce(owner_name, '') || ' ' ||
                coalesce(phone, '') || ' ' ||
                coalesce(email, '') || ' ' ||
                coalesce(address ->> 'city', '') || ' ' ||
                coalesce(address ->> 'address', '') || ' ' ||
                coalesce(address ->> 'zip_code', ''))
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
