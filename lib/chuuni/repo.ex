defmodule Chuuni.Repo do
  use Ecto.Repo,
    otp_app: :chuuni,
    adapter: Ecto.Adapters.Postgres
end
