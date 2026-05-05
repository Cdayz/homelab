DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'coder'
    ) THEN
        DROP USER coder;
    END IF;
END $$;
