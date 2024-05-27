defmodule Plotlix.Repo do
  use Ecto.Repo,
    otp_app: :plotlix,
    adapter: Ecto.Adapters.Postgres
end
