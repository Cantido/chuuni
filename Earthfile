VERSION 0.6

ARG MIX_ENV=dev

all:
  BUILD +check
  BUILD +test
  BUILD +docker

deps:
  FROM elixir:1.15
  ARG MIX_ENV
  COPY mix.exs .
  COPY mix.lock .

  RUN apt update \
      && apt upgrade -y \
      && mix local.rebar --force \
      && mix local.hex --force \
      && mix deps.get

build:
  FROM +deps

  COPY --dir lib/ test/ config/ priv/ assets/ rel/ ./
  RUN mix compile

check:
  FROM +build --MIX_ENV=dev

  RUN mix check

test:
  FROM +build --MIX_ENV=test

  COPY docker-compose.dev.yml .

  RUN mkdir /artwork

  ENV CHUUNI_ARTWORK_PATH /artwork
  ENV CHUUNI_VAULT_KEY=aJ7HcM24BcyiwsAvRsa3EG3jcvaFWooyQJ+91OO7bRU=

  WITH DOCKER --compose docker-compose.dev.yml
    RUN echo "Waiting 10s for DB to be ready..."  && \
        sleep 10 && \
        mix do ecto.create, ecto.migrate, test
  END

release:
  FROM +build

  RUN mix assets.deploy
  RUN mix release

  SAVE ARTIFACT _build/$MIX_ENV/rel

docker:
  FROM debian:bullseye
  WORKDIR /app

  RUN apt update && apt upgrade -y \
    && apt install -y locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

  ENV LANG en_US.UTF-8
  ENV LANGUAGE en_US:en
  ENV LC_ALL en_US.UTF-8

  COPY --dir --build-arg MIX_ENV=prod +release/rel .

  ENV DATABASE_URL
  ENV SECRET_KEY_BASE

  ENV MIX_ENV=prod

  ENTRYPOINT ["/app/rel/chuuni/bin/chuuni"]
  CMD ["server"]

  SAVE IMAGE --push ghcr.io/cantido/chuuni:latest
