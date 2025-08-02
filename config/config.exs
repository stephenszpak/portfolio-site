# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :szpak_portfolio,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :szpak_portfolio, SzpakPortfolioWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SzpakPortfolioWeb.ErrorHTML, json: SzpakPortfolioWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SzpakPortfolio.PubSub,
  live_view: [
    signing_salt: "dz3eDxyF",
    # Increase session timeout for better cross-browser compatibility
    session_timeout: 30 * 60 * 1000, # 30 minutes
    # Better transport configuration for Safari/Edge
    transport_options: [
      timeout: 30_000,
      transport_log: false,
      check_origin: false
    ]
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :szpak_portfolio, SzpakPortfolio.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  szpak_portfolio: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  szpak_portfolio: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
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
