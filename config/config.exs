# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :chuuni,
  ecto_repos: [Chuuni.Repo]

config :chuuni, :generators,
  binary_id: true

config :chuuni, Chuuni.Repo,
  migration_primary_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :chuuni, ChuuniWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ChuuniWeb.ErrorHTML, json: ChuuniWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Chuuni.PubSub,
  live_view: [signing_salt: "g4+x6aQz"]

config :chuuni, Oban,
  repo: Chuuni.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    federator_incoming: 50,
    federator_outgoing: 50,
    remote_fetcher: 20
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :chuuni, Chuuni.Mailer, adapter: Swoosh.Adapters.Local

config :activity_pub,
  adapter: Chuuni.ActivityPub.Adapter,
  repo: Chuuni.Repo,
  mrf_simple: [
    media_removal: [],
    media_nsfw: [],
    report_removal: [],
    accept: [],
    avatar_removal: [],
    banner_removal: []
  ],
  instance: [
    hostname: "localhost:4000",
    federation_publisher_modules: [ActivityPub.Federator.APPublisher],
    federation_reachability_timeout_days: 7,
    federating: true,
    rewrite_policy: []
  ],
  http: [
    proxy_url: nil,
    user_agent: "chuuni",
    send_user_agent: true,
    adapter: [
      ssl_options: [
        # Workaround for remote server certificate chain issues
        partial_chain: &:hackney_connect.partial_chain/1,
        # We don't support TLS v1.3 yet
        versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
      ]
    ]
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  js: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  css: [
    args:
      ~w(css/app.css --bundle --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
