defmodule Core.Repo.Migrations.AlterDBFunctionCalculateDistance do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("DROP FUNCTION IF EXISTS calculate_distance(GEOMETRY, VARCHAR, JSONB);")

    execute("""
    CREATE OR REPLACE FUNCTION calculate_distance(location GEOMETRY, branch_location VARCHAR, distance JSONB DEFAULT '{"distance_limit": 30}', input_distance JSONB DEFAULT '{}')
    RETURNS BOOLEAN AS $$
    DECLARE
    distance_limit FLOAT;
    status BOOLEAN = FALSE;
    BEGIN
    IF TRIM(input_distance ->> 'distance') NOTNULL THEN
        distance_limit := TRIM(input_distance ->> 'distance') :: FLOAT;
    ELSE
        IF TRIM(distance ->> 'distance_limit') NOTNULL THEN
          distance_limit := TRIM(distance ->> 'distance_limit') :: FLOAT;
        ELSE
          distance_limit := 30;
        end if;
    end if;
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
