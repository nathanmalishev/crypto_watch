defmodule Coinjar.Repo.Migrations.CreateCoins do
  use Ecto.Migration

  def change do
    create table(:coins) do
      add :last, :float
      add :bid, :float
      add :ask, :float
      add :coin, :string, null: false
      timestamps()
    end
  end
end
