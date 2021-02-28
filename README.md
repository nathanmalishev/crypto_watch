# Coinjar

To start your Get Up and running:

  * Start your postgres server `docker run -d -p 5432:5432 --name my-postgres -e POSTGRES_PASSWORD=mysecretpassword postgres`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`


Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Notes

Decieded to use a postgres server as it was the easiest option since it's baked into ecto / phoenix eco system. Otherwise i honestly probably would have used a json file, or just have the previously saved prices in-memory. I would justify this by saying elixir/phoenix is incredibily stable and there is no requirements that saved prices must be persisted long term.
