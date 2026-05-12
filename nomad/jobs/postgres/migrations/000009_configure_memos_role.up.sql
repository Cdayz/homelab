DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'memos') THEN

      RAISE NOTICE 'Role "memos" already exists. Skipping.';
   ELSE
      CREATE USER memos PASSWORD NULL;
   END IF;
END $$;
