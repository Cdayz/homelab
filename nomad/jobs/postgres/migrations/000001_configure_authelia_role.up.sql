DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'authelia') THEN

      RAISE NOTICE 'Role "authelia" already exists. Skipping.';
   ELSE
      CREATE USER authelia PASSWORD NULL;
   END IF;
END $$;
