defmodule Coinjar.Coin do
  @moduledoc """
  Coin implements our coin module. From this module you can fetch the latest prices, save them to the databse or view previously saved coin prices. 
  """
  use Ecto.Schema
  require PipeLogger

  require Logger
  alias Coinjar.Coin, as: Coin

  schema "coins" do
    field :last, :float
    field :bid, :float
    field :ask, :float
    field :coin, :string
    timestamps()
  end

  @type_map %{
    last: :float,
    bid: :float,
    ask: :float,
    coin: :string
  }

  @doc """
  Create a changeset of Coin
  """
  def changeset(stock, params \\ %{}) do
    {stock, @type_map}
    |> Ecto.Changeset.cast(params, Map.keys(@type_map))
  end

  @doc """
  Casts our map to a coin, runs any validation
  """
  def cast_struct(map) do
    {%Coin{}, @type_map}
    |> Ecto.Changeset.cast(map, Map.keys(@type_map))
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Fetch's the latest price & then saves that price to the database
  """
  def save_latest(coin) when is_atom(coin) do
    {:ok, coin_obj} = fetch_latest(coin)

    Coinjar.Repo.insert(coin_obj)
  end

  @doc """
  Fetch's all the saved prices users have stored. 
  """
  def fetch_saved() do
    Coinjar.Repo.all(Coin)
  end

  ## Fetch & handle latest data source
  @spec fetch_latest(%Coin{}) :: {:ok, %Coin{}} | {:error, charlist()}
  def fetch_latest(coin_code) when is_atom(coin_code) do
    create_url(coin_code)
    |> (&PipeLogger.debug(&1, "Fetching url:#{&1}")).()
    |> HTTPoison.get()
    |> handle_fetch(coin_code)
  end

  defp handle_fetch({:ok, %HTTPoison.Response{status_code: 200, body: body}}, coin_code) do
    Jason.decode!(body, keys: :atoms)
    |> Map.put(:coin, coin_to_string(coin_code))
    |> Coin.cast_struct()
  end

  defp handle_fetch({:ok, %HTTPoison.Response{status_code: 404}}, coin_code) do
    {:error, "Coin: #{coin_code} not found"}
  end

  defp handle_fetch({:error, %HTTPoison.Error{}}, _coin_code) do
    {:error, "Something went wrong, please try again later"}
  end

  ## Helpers 

  defp create_url(coin) when is_atom(coin) do
    coin_str = coin_to_string(coin)
    "https://data.exchange.coinjar.com/products/#{String.upcase(coin_str)}AUD/ticker"
  end

  @doc """
  Takes a possible string to the atomized form of the coin name
  """
  def string_to_coin(coin) when is_binary(coin) do
    String.to_existing_atom(coin)
  end

  @doc """
  Takes a the coin atom to it's string equivalent
  """
  def coin_to_string(coin) when is_atom(coin) do
    Atom.to_string(coin)
  end
end
