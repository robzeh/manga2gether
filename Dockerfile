FROM elixir:1.12.1-alpine

# build dependencies
RUN apk add --no-cache make gcc libc-dev npm postgresql-client

WORKDIR /app

# Install hex & rebar
RUN mix local.hex --force && \
	mix local.rebar --force

# mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progess-false --no-audit --loglevel=error

COPY entrypoint.sh ./

CMD ["sh", "/app/entrypoint.sh"]