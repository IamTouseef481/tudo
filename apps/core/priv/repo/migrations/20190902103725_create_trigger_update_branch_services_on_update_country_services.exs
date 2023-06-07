defmodule Core.Repo.Migrations.CreateTriggerUpdateBranchServicesOnUpdatecCountryServices do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION update_branch_services_on_country_service_update()
    RETURNS TRIGGER AS
    $BODY$
    BEGIN
    RAISE NOTICE 'new: %,old %',NEW.is_active,old.is_active;
    IF NEW.is_active = FALSE THEN
      RAISE NOTICE 'country service is in deactivating--';
      UPDATE branch_services SET is_active = FALSE WHERE branch_services.country_service_id = new.id;
    END IF;
    RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
      DROP TRIGGER IF EXISTS update_branch_services_on_country_service_update ON country_services;
    """)

    execute("""
      CREATE TRIGGER update_branch_services_on_country_service_update
        AFTER UPDATE
        ON country_services
        FOR EACH ROW
        WHEN (OLD.is_active IS DISTINCT FROM NEW.is_active)
      EXECUTE PROCEDURE update_branch_services_on_country_service_update();
    """)
  end

  def down do
    execute(
      "DROP TRIGGER IF EXISTS update_branch_services_on_country_service_update ON country_services;"
    )

    execute("DROP FUNCTION IF EXISTS update_branch_services_on_country_service_update();")
  end
end
