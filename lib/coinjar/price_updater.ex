defmodule Coinjar.PriceUpdater do
  use GenServer

  require Logger

  alias Coinjar.Coin, as: Coin
  alias Phoenix.PubSub, as: PubSub

  @time_interval 20000

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  def init(coin) do
    schedule_work(coin, %{})
    {:ok, %{}}
  end

  def handle_call({:get, coin}, _from, prices) do
    {:reply, Map.fetch!(prices, coin), prices}
  end

  def handle_info({:update, coin}, prices) do
    {:ok, coin_obj} = Coin.fetch_latest(coin)

    schedule_work(coin, prices)
    PubSub.broadcast(:coins, Coin.coin_to_string(coin), coin_obj)
    {:noreply, Map.put(prices, coin, coin_obj)}
  end

  defp schedule_work(coin, prices) when is_atom(coin) and is_map(prices) do
    Process.send_after(self(), {:update, coin}, @time_interval)
  end

  ## client API
  # def update_coin(pid, coin) do
  # GenServer.cast(pid, {:update, coin})
  # end

  def get_price(pid, coin) do
    GenServer.call(pid, {:get, coin})
  end
end
