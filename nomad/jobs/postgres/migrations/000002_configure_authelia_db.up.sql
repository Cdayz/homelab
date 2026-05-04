CREATE EXTENSION IF NOT EXISTS dblink;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'authelia'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'CREATE DATABASE authelia OWNER authelia;');
    END IF;
END $$;
