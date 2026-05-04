CREATE EXTENSION IF NOT EXISTS dblink;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'immich'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'CREATE DATABASE immich OWNER immich;');
    END IF;
END $$;
