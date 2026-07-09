DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rw_dwh') THEN
    CREATE ROLE rw_dwh NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ro_marts') THEN
    CREATE ROLE ro_marts NOLOGIN;
  END IF;
END $$;

COMMENT ON ROLE rw_dwh   IS 'Группа ETL: права на stg/dds/dm/meta/ext (член — airflow)';
COMMENT ON ROLE ro_marts IS 'Группа BI: чтение dm + EXECUTE rep (член — metabase)';


DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'airflow') THEN
    CREATE ROLE airflow LOGIN CONNECTION LIMIT 20;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'metabase') THEN
    CREATE ROLE metabase LOGIN CONNECTION LIMIT 20;
  END IF;
END $$;


DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_auth_members m
                 JOIN pg_roles r ON r.oid = m.roleid
                 JOIN pg_roles mbr ON mbr.oid = m.member
                 WHERE r.rolname='rw_dwh' AND mbr.rolname='airflow') THEN
    GRANT rw_dwh TO airflow;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_auth_members m
                 JOIN pg_roles r ON r.oid = m.roleid
                 JOIN pg_roles mbr ON mbr.oid = m.member
                 WHERE r.rolname='ro_marts' AND mbr.rolname='metabase') THEN
    GRANT ro_marts TO metabase;
  END IF;
END $$;

COMMENT ON ROLE airflow IS 'Техническая учётка Airflow';
COMMENT ON ROLE metabase IS 'Техническая учётка Metabase';
