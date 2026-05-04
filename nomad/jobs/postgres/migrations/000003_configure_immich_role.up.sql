DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'immich') THEN

      RAISE NOTICE 'Role "immich" already exists. Skipping.';
   ELSE
      CREATE USER immich PASSWORD NULL;
   END IF;
END $$;
