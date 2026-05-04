DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'authelia'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'DROP DATABASE authelia;');
    END IF;
END $$;
