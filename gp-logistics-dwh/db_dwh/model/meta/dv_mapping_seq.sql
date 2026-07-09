DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind = 'S' AND n.nspname = 'meta' AND c.relname = 'dv_mapping_seq'
    ) THEN
        CREATE SEQUENCE meta.dv_mapping_seq;
    END IF;
END $$;
