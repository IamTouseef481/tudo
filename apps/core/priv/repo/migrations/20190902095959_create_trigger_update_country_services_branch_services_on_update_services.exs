defmodule Core.Repo.Migrations.CreateTriggerUpdateCountryServicesBranchServicesOnUpdateServices do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION update_country_services_branch_services_on_service_update()
    RETURNS TRIGGER AS
    $BODY$
    BEGIN
    RAISE NOTICE 'new: %,old %',NEW.service_status_id,old.service_status_id;
    IF NEW.service_status_id = 'in_active' THEN
      RAISE NOTICE 'service is in deactivating--';
      UPDATE country_services SET is_active = FALSE WHERE country_services.service_id = old.id;
      UPDATE branch_services SET is_active = FALSE from country_services WHERE branch_services.country_service_id = country_services.id AND country_services.service_id = old.id;
    END IF;
    RETURN NEW;
    END
    $BODY$
    LANGUAGE plpgsql;
    """)

    execute("""
      DROP TRIGGER IF EXISTS update_country_services_branch_services_on_service_update ON services;
    """)

    execute("""
      CREATE TRIGGER update_country_services_branch_services_on_service_update
        AFTER UPDATE
        ON services
        FOR EACH ROW
        WHEN (OLD.service_status_id IS DISTINCT FROM NEW.service_status_id)
      EXECUTE PROCEDURE update_country_services_branch_services_on_service_update();
    """)
  end

  def down do
    execute(
      "DROP TRIGGER IF EXISTS update_country_services_branch_services_on_service_update ON services;"
    )

    execute(
      "DROP FUNCTION IF EXISTS update_country_services_branch_services_on_service_update();"
    )
  end
end
