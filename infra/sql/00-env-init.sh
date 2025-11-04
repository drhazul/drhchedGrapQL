#!/bin/sh
set -e

: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_PASSWORD:=changeme}"

cat > /docker-entrypoint-initdb.d/01-init-from-env.sql <<SQL
-- Archivo generado dinámicamente desde 00-env-init.sh
-- Usa las variables del contenedor: POSTGRES_USER / POSTGRES_PASSWORD

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${POSTGRES_USER}') THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', '${POSTGRES_USER}', '${POSTGRES_PASSWORD}');
  ELSE
    EXECUTE format('ALTER ROLE %I WITH LOGIN PASSWORD %L', '${POSTGRES_USER}', '${POSTGRES_PASSWORD}');
  END IF;
END
\$\$;

-- Crea base de datos de desarrollo si no existe y la asigna al dueño correcto
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'drhched_dev') THEN
    EXECUTE format('CREATE DATABASE %I OWNER %I', 'drhched_dev', '${POSTGRES_USER}');
  END IF;
END
\$\$;
SQL
