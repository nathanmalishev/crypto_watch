defmodule Coinjar.PriceUpdater do
  @moduledoc """
  This module asynchronously handles the fetching of coin prices. It's handled in one central location seperate to the live view. So if it crashes it should not affect the liveview & can restart in the background. Secondly for multiple connecting clients we are only polling the API's in one place.
  """
  use GenServer

  require Logger

  alias Coinjar.Coin, as: Coin
  alias Phoenix.PubSub, as: PubSub

  @time_interval 20000

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: init_arg)
  end

  def init(coin) do
    schedule_work(coin, %{})
    {:ok, %{}}
  end

  def handle_call({:get, coin}, _from, prices) do
    {:reply, Map.fetch!(prices, coin), prices}
  end

  def handle_cast({:update, coin}, prices) do
    ## Once of call, we do not reschedule work here
    {:ok, coin_obj} = Coin.fetch_latest(coin)

    PubSub.broadcast(Coinjar.PubSub, Coin.coin_to_string(coin), coin_obj)
    {:noreply, Map.put(prices, coin, coin_obj)}
  end

  def handle_info({:update, coin_name}, prices) do
    ## Our background timer going off
    {:ok, coin_obj} = Coin.fetch_latest(coin_name)

    schedule_work(coin_name, prices)
    PubSub.broadcast(Coinjar.PubSub, Coin.coin_to_string(coin_name), coin_obj)
    {:noreply, Map.put(prices, coin_name, coin_obj)}
  end

  defp schedule_work(coin, prices) when is_atom(coin) and is_map(prices) do
    Process.send_after(self(), {:update, coin}, @time_interval)
  end

  ## Client API
  def update_coin(pid, coin) do
    GenServer.cast(pid, {:update, coin})
  end

  def get_price(pid, coin) do
    GenServer.call(pid, {:get, coin})
  end
end
