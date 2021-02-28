defmodule CoinjarWeb.CoinsLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  require Logger

  def render_coin_price(price) when is_float(price) do
    price |> :erlang.float_to_binary([:compact, {:decimals, 10}])
  end

  def render(assigns) do
    ## Could be seperated out on it's own page at a later date
    ~L"""
    <div style="display:flex;flex-direction:row;">
      <%= Enum.map @coins, fn {_k, coin} -> %>
        <div style="width:400px">
          <p> Coin: <%= coin.coin %> </p>
          <p> ask: <%= render_coin_price(coin.ask) %> </p>
          <p> bid: <%= render_coin_price(coin.bid) %> </p>
          <p> Last: <%= render_coin_price(coin.last) %> </p>
          <button> save price </button>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Trigger latest price on refresh, inefficent as every refresh triggers another call
    # At this point you would start to look at saving lastest tick
    Coinjar.PriceUpdater.update_coin(:btc, :btc)
    Coinjar.PriceUpdater.update_coin(:eth, :eth)

    # Sub to pubsub for latest prices
    :ok = Phoenix.PubSub.subscribe(Coinjar.PubSub, "btc")
    :ok = Phoenix.PubSub.subscribe(Coinjar.PubSub, "eth")

    {:ok, assign(socket, :coins, %{})}
  end

  def handle_info(coin, socket) do
    ## Handles subscribe ticks
    {:noreply, fetch(socket, coin)}
  end

  def fetch(socket, coin) do
    coin |> inspect |> Logger.debug()
    # socket.assigns.coins |> inspect |> Logger.debug()
    Logger.debug("reciveing #{coin.coin}")

    assign(socket, coins: Map.put(socket.assigns.coins, coin.coin, coin))
  end
end
