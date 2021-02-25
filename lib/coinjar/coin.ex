defmodule Coinjar.Coin do
  use Ecto.Schema
  require PipeLogger

  schema "crypto" do
    field :last, :float
    field :bid, :float
    field :ask, :float
    field :coin, :string
    embeds_one :user, Coinjar.User, on_replace: :update
    timestamps()
  end

  @type_map %{
    last: :float,
    bid: :float,
    ask: :float,
    coin: :string
  }

  def changeset(stock, params \\ %{}) do
    {stock, @type_map}
    |> Ecto.Changeset.cast(params, Map.keys(@type_map))
  end

  def cast_struct(map) do
    {%Coinjar.Coin{}, @type_map}
    |> Ecto.Changeset.cast(map, Map.keys(@type_map))
    |> Ecto.Changeset.apply_action(:update)
  end

  ## Fetch & handle latest data source
  def fetch_latest(coin_code) when is_atom(coin_code) do
    ## fetch a crypto currency

    create_url(coin_code)
    |> (&PipeLogger.debug(&1, "Fetching url:#{&1}")).()
    |> HTTPoison.get()
    |> handle_fetch(coin_code)
  end

  defp handle_fetch({:ok, %HTTPoison.Response{status_code: 200, body: body}}, coin_code) do
    Jason.decode!(body, keys: :atoms)
    |> Map.put(:coin, coin_to_string(coin_code))
    |> Coinjar.Coin.cast_struct()
  end

  defp handle_fetch({:ok, %HTTPoison.Response{status_code: 404}}, coin_code) do
    {:error, "Coin: #{coin_code} not Found"}
  end

  defp handle_fetch({:error, %HTTPoison.Error{}}, _coin_code) do
    {:error, "Something went wrong, please try again later"}
  end

  ## Helpers 

  defp create_url(coin) when is_atom(coin) do
    coin_str = coin_to_string(coin)
    "https://data.exchange.coinjar.com/products/#{String.upcase(coin_str)}AUD/ticker"
  end

  def string_to_coin(coin) when is_binary(coin) do
    String.to_existing_atom(coin)
  end

  def coin_to_string(coin) when is_atom(coin) do
    Atom.to_string(coin)
  end
end
