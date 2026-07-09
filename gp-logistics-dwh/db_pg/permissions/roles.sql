DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pxf_reader') THEN
    CREATE ROLE pxf_reader LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'etl_src') THEN
    CREATE ROLE etl_src LOGIN;
  END IF;
END $$;

COMMENT ON ROLE pxf_reader IS 'Учётка PXF-сервера pgsrc';
COMMENT ON ROLE etl_src    IS 'Учётка ETL источника';
