DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'authelia'
    ) THEN
        DROP USER authelia;
    END IF;
END $$;
