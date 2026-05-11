DO $$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'postgres_exporter') THEN

      RAISE NOTICE 'Role "postgres_exporter" already exists. Skipping.';
   ELSE
      CREATE USER postgres_exporter PASSWORD NULL;
      GRANT pg_monitor TO postgres_exporter;
   END IF;
END $$;
