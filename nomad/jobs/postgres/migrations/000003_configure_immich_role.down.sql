DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'immich'
    ) THEN
        DROP USER immich;
    END IF;
END $$;
