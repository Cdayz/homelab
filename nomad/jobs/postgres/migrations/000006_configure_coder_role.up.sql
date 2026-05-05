DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'coder') THEN

      RAISE NOTICE 'Role "coder" already exists. Skipping.';
   ELSE
      CREATE USER coder PASSWORD NULL;
   END IF;
END $$;
