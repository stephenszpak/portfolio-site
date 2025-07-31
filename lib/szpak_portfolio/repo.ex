defmodule SzpakPortfolio.Repo do
  use Ecto.Repo,
    otp_app: :szpak_portfolio,
    adapter: Ecto.Adapters.Postgres
end
