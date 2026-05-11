DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'postgres_exporter'
    ) THEN
        DROP USER postgres_exporter;
    END IF;
END $$;
