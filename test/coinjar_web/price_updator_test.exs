defmodule PriceUpdaterTest do
  use ExUnit.Case

  import Mock
  require Logger

  test "Updator fetch's new prices" do
    with_mocks([
      {HTTPoison, [],
       [
         get: fn url ->
           {:ok,
            %HTTPoison.Response{
              status_code: 200,
              body: '{"ask": 1.0, "last": 3.0, "coin":"btc", "bid":2.0}'
            }}
         end
       ]},
      {Phoenix.PubSub, [], [broadcast: fn _module, _coinname, _coin -> :ok end]}
    ]) do
      updated_price = Coinjar.PriceUpdater.handle_cast({:update, :btc}, %{})

      coin = %Coinjar.Coin{bid: 2.0, ask: 1.0, last: 3.0, coin: "btc"}
      expected_pubsub = {Phoenix.PubSub, :broadcast, [Coinjar.PubSub, "btc", coin]}

      {_pid, actual_pubsub, :ok} = List.first(call_history(Phoenix.PubSub))

      # start_supervised(Coinjar.PubSub, name: Coinjar.PubSub)
      assert updated_price == {:noreply, %{btc: coin}}
      assert actual_pubsub == expected_pubsub
    end
  end
end
