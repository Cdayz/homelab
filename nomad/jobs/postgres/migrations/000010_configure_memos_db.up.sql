CREATE EXTENSION IF NOT EXISTS dblink;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'memos'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'CREATE DATABASE memos OWNER memos;');
    END IF;
END $$;
