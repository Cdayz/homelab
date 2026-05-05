DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_database WHERE datname = 'coder'
    ) THEN
        PERFORM dblink_exec('dbname=' || current_database()  -- current db
                        , 'DROP DATABASE coder;');
    END IF;
END $$;
