defmodule Core.Repo.Migrations.CreateDBFunctions do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION is_available(availability JSONB, job_time TIMESTAMP)
    RETURNS BOOLEAN AS $$
    DECLARE
    av     JSON;
    i      JSON;
    difference VARCHAR(20);
    utc_difference VARCHAR(20);
    op VARCHAR(2);
    status BOOLEAN = FALSE;

    BEGIN
    utc_difference := availability->'utc_difference';
    difference := substring(utc_difference, 3, 8);
    op := substring(utc_difference, 2, 1);
    job_time := CASE WHEN op = '+' THEN (job_time + difference :: INTERVAL) WHEN op = '-' THEN (job_time - difference :: INTERVAL) END;
    av := availability -> TRIM(to_char(job_time, 'day'));
    FOR i IN SELECT *
           FROM json_array_elements(av)
    LOOP
    IF cast(job_time AS TIME) BETWEEN TRIM(i ->> 'from') :: TIME AND TRIM(i ->> 'to') :: TIME
    THEN
      status := TRUE;
    END IF;
    IF status = TRUE
    THEN
      EXIT;
    END IF;
    END LOOP;

    RETURN status;

    END;
    $$
    LANGUAGE plpgsql;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION is_available_for_arrive_at(availability JSONB, job_time TIMESTAMP)
    RETURNS BOOLEAN AS $$
    DECLARE
    av     JSON;
    shift  VARCHAR(2);
    i      JSON;
    difference VARCHAR(20);
    utc_difference VARCHAR(20);
    op VARCHAR(2);
    status BOOLEAN = FALSE;

    BEGIN
    av := availability -> TRIM(to_char(job_time, 'day'));
    shift := (SELECT jsonb_object_keys(av :: JSONB) LIMIT 1);
    av := av ->> shift;

    FOR i IN SELECT *
             FROM json_array_elements(av)
        LOOP
            IF TRIM(i ->> 'from') :: TIME > cast(job_time AS TIME) OR TRIM(i ->> 'to') :: TIME > cast(job_time AS TIME)
            THEN
                status := TRUE;
            END IF;
            IF status = TRUE
            THEN
                EXIT;
            END IF;
        END LOOP;

    RETURN status;

    END;
    $$
    LANGUAGE plpgsql;
    """)

    execute("""
      CREATE OR REPLACE FUNCTION filter_zone(zone_ids INT [], current_point VARCHAR)
        RETURNS BOOLEAN AS $$
      DECLARE
        i      GEOMETRY;
        status BOOLEAN = FALSE;
      BEGIN
        IF ARRAY_LENGTH(zone_ids, 1) IS NULL OR ARRAY_LENGTH(zone_ids, 1) < 1
        THEN
          status := TRUE;
        ELSE
          FOR i IN SELECT coordinates
                  FROM geo_zones
                  WHERE id = ANY (zone_ids)
          LOOP
            status := ST_Contains(i, current_point :: GEOMETRY);
            IF status = TRUE
            THEN
              EXIT;
            END IF;
          END LOOP;
        END IF;

        RETURN status;

      END;
      $$
      LANGUAGE plpgsql;
    """)

    execute("""
      CREATE OR REPLACE FUNCTION scheduled_job_filter(arrive_at       TIMESTAMP, expected_work_duration TIME,
                                                      job_posted_date TIMESTAMP)
        RETURNS BOOLEAN AS $$
      DECLARE
        status BOOLEAN := TRUE;
      BEGIN
        IF job_posted_date BETWEEN arrive_at AND (arrive_at + expected_work_duration)
        THEN
          status := FALSE;
        END IF;
        RETURN status;
      END;

      $$
      LANGUAGE plpgsql;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION calculate_distance(location GEOMETRY, branch_location VARCHAR, distance JSONB DEFAULT '{"distance_limit": 30}')
    RETURNS BOOLEAN AS $$
    DECLARE
    distance_limit INTEGER;
    status BOOLEAN = FALSE;
    BEGIN
    IF TRIM(distance ->> 'distance_limit') NOTNULL THEN
        distance_limit := TRIM(distance ->> 'distance_limit') :: INTEGER;
    ELSE
        distance_limit := 30;
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

    execute("""
      CREATE OR REPLACE FUNCTION filter_scheduled_jobs(schedule JSONB, arrive_at TIMESTAMP, expected_work_duration TIME, fields JSONB DEFAULT '{"is_flexible": false}')
      RETURNS BOOLEAN AS $$
      DECLARE
      av     JSON;
      i      JSON;
      jobs   JSON;
      counter INTEGER := 0;
      old_arrive_at TIMESTAMP;
      old_job_end_time TIMESTAMP;
      new_job_end_time TIMESTAMP;
          backward_arrive_at TIMESTAMP;
          forward_arrive_at TIMESTAMP;
          backward_job_end_time TIMESTAMP;
      forward_job_end_time TIMESTAMP;
      difference VARCHAR(20);
      utc_difference VARCHAR(20);
      op VARCHAR(2);
      status BOOLEAN = TRUE;
      is_flexible BOOLEAN;

    BEGIN
      jobs := schedule->'jobs';

      IF fields NOTNULL THEN
          is_flexible := TRIM(fields ->> 'is_flexible') :: BOOLEAN;
              ELSE
                  is_flexible := FALSE;
              end if;

      new_job_end_time := arrive_at + expected_work_duration;
      RAISE NOTICE '----------------arrive_at';
      RAISE NOTICE '%', is_flexible;
      RAISE NOTICE '%', arrive_at;
      RAISE NOTICE '%', new_job_end_time;
      RAISE NOTICE '----------------arrive_at';
      FOR i IN SELECT * FROM json_array_elements(jobs)
          LOOP
              old_arrive_at := TRIM(i ->> 'arrive_at') :: TIMESTAMP;
              old_job_end_time := old_arrive_at +  TRIM(i ->> 'expected_work_duration') :: TIME;

                          RAISE NOTICE '----------------old_job_end_time';
                          RAISE NOTICE '%', old_arrive_at;
                          RAISE NOTICE '%', old_job_end_time;
                                      RAISE NOTICE '----------------old_job_end_time';

                                      IF (arrive_at BETWEEN old_arrive_at AND old_job_end_time) OR (new_job_end_time BETWEEN old_arrive_at AND old_job_end_time)
                                      THEN
                                                      status := FALSE;
                                                  END IF;

                                                  IF status = FALSE AND is_flexible
                                                              THEN
                                                                  RAISE NOTICE '----------------new_arrive_at';
                                                                  LOOP
                                  EXIT WHEN counter = 10;
                                  counter := counter + 5;
                                  difference := CONCAT('00:0', counter,':00');
                                  RAISE NOTICE '----------------difference';
                                  RAISE NOTICE '%', difference;
                                  RAISE NOTICE '----------------difference';

                                  backward_arrive_at := (arrive_at - difference :: INTERVAL);
                                  backward_job_end_time := backward_arrive_at + expected_work_duration;
                                  forward_arrive_at := (arrive_at + difference  :: INTERVAL);
                                  forward_job_end_time := forward_arrive_at + expected_work_duration;

                                                      RAISE NOTICE '----------------status';
                                                      RAISE NOTICE '%', status;
                                                      RAISE NOTICE 'backward_arrive_at';
                                                                          RAISE NOTICE '%', backward_arrive_at;
                                                                          RAISE NOTICE '%', backward_job_end_time;
                                                                          RAISE NOTICE 'backward_arrive_at';
                                  RAISE NOTICE '%', forward_arrive_at;
                                  RAISE NOTICE '%', forward_job_end_time;
                                  RAISE NOTICE '----------------status';
                      RAISE NOTICE '1st % between % and %: %', backward_arrive_at, old_arrive_at, old_job_end_time, (backward_arrive_at NOT BETWEEN old_arrive_at AND old_job_end_time);
                      RAISE NOTICE '2nd % between % and %: %', backward_job_end_time, old_arrive_at, old_job_end_time, (backward_job_end_time NOT BETWEEN old_arrive_at AND old_job_end_time);
                      RAISE NOTICE '3rd % between % and %: %', forward_arrive_at, old_arrive_at, old_job_end_time, (forward_arrive_at NOT BETWEEN old_arrive_at AND old_job_end_time);
                      RAISE NOTICE '4th % between % and %: %', forward_job_end_time, old_arrive_at, old_job_end_time, (forward_job_end_time NOT BETWEEN old_arrive_at AND old_job_end_time);
                                          RAISE NOTICE '----------------status';


                                          IF ((backward_arrive_at NOT BETWEEN old_arrive_at AND old_job_end_time) AND (backward_job_end_time NOT BETWEEN old_arrive_at AND old_job_end_time))
                          OR ((forward_arrive_at NOT BETWEEN old_arrive_at AND old_job_end_time) AND (forward_job_end_time NOT BETWEEN old_arrive_at AND old_job_end_time))
                      THEN
                          status := TRUE;
                      END IF;

                                          IF status = TRUE
                                          THEN
                                              EXIT;
                                                                  END IF;
                                                              END LOOP ;
                                                          END IF;
              IF status = FALSE
              THEN
                  EXIT;
              END IF;
          END LOOP;
    RETURN status;

    END;
    $$
    LANGUAGE plpgsql;
    """)
  end

  def down do
    execute("DROP FUNCTION calculate_distance(GEOMETRY, GEOMETRY, JSONB);")
    execute("DROP FUNCTION filter_scheduled_jobs(JSON, TIMESTAMP, TIME, BOOLEAN);")
    execute("DROP FUNCTION scheduled_job_filter(TIMESTAMP,TIME,TIMESTAMP) ;")
    execute("DROP FUNCTION filter_zone(int[],VARCHAR);")
    execute("DROP FUNCTION is_available(jsonb,TIMESTAMP);")
    execute("DROP FUNCTION is_available_for_arrive_at(jsonb,TIMESTAMP);")
  end
end
