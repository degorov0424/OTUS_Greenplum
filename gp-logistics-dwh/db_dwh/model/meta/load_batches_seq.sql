DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind = 'S' AND n.nspname = 'meta' AND c.relname = 'load_batches_seq'
    ) THEN
        CREATE SEQUENCE meta.load_batches_seq;
    END IF;
END $$;
