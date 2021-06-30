#!/bin/bash

# Wait until Postgres is ready
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$PGHOST $PGPORT $PGUSER"
  echo "$(date) - waiting for database"	
  sleep 2
done

# Create, migrate and seed database if it doesn't exist
if [[ -z `psql -Atqc "\\list $PGDATABSSE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
	createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
	mix ecto.migrate
	# mix run priv/repo/seeds.exs
	echo "Database $PGDATABASE created"
fi

exec mix phx.server