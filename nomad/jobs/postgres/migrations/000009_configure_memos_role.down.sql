DO $$
BEGIN
    IF EXISTS (
        SELECT FROM pg_user WHERE usename = 'memos'
    ) THEN
        DROP USER memos;
    END IF;
END $$;
