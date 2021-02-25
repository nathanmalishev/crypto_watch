defmodule Coinjar.Repo do
  use Ecto.Repo,
    otp_app: :coinjar,
    adapter: Ecto.Adapters.Postgres
end
