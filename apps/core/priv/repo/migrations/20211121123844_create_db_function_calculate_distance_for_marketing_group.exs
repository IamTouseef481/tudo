defmodule Core.Repo.Migrations.CreateDBFunctionCalculateDistanceForMarketingGroup do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute(
      "DROP FUNCTION IF EXISTS calculate_distance_for_marketing_group(GEOMETRY, GEOMETRY, FLOAT);"
    )

    execute("""
    CREATE OR REPLACE FUNCTION calculate_distance_for_marketing_group(location GEOMETRY, branch_location GEOMETRY, distance_limit FLOAT DEFAULT 150)
    RETURNS BOOLEAN AS $$
    DECLARE
    status BOOLEAN = FALSE;
    BEGIN
    location := concat('SRID=4326;POINT(',ST_Y(location::geometry), ' ', ST_X(location::geometry),')');
    branch_location := concat('SRID=4326;POINT(',ST_Y(branch_location::geometry), ' ', ST_X(branch_location::geometry),')');
    RAISE NOTICE 'distance limit: %', distance_limit;
    RAISE NOTICE 'distance: %', ST_Distance(location::GEOGRAPHY,branch_location::GEOGRAPHY)/1000;
    RAISE NOTICE 'distance: %', (ST_Distance(location::GEOGRAPHY, branch_location::GEOGRAPHY)/1000) <= distance_limit;

    IF (ST_Distance(location::GEOGRAPHY, branch_location::GEOGRAPHY)/1000) <= distance_limit THEN
        status := TRUE;
    END IF;

    RETURN status;
    END;
    $$
    LANGUAGE plpgsql;
    """)
  end
end
