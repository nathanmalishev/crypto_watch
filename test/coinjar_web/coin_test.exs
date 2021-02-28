defmodule CoinTest do
  use ExUnit.Case

  import Mock
  require Logger

  test "Handle fetch latest - 200 response" do
    with_mocks([
      {HTTPoison, [],
       [
         get: fn _url ->
           {:ok,
            %HTTPoison.Response{
              status_code: 200,
              body: '{"ask": 1.0, "last": 3.0, "coin":"btc", "bid":2.0}'
            }}
         end
       ]}
    ]) do
      expected = %Coinjar.Coin{bid: 2.0, ask: 1.0, last: 3.0, coin: "btc"}
      assert {:ok, expected} == Coinjar.Coin.fetch_latest(:btc)
    end
  end

  test "Handle fetch latest - 404 response" do
    with_mocks([
      {HTTPoison, [],
       [
         get: fn _url ->
           {:ok,
            %HTTPoison.Response{
              status_code: 404,
              body: 'Coin not found'
            }}
         end
       ]}
    ]) do
      expected = {:error, "Coin: btc not found"}
      assert expected == Coinjar.Coin.fetch_latest(:btc)
    end
  end

  test "Handle fetch latest - Error response" do
    with_mocks([
      {HTTPoison, [],
       [
         get: fn _url ->
           {:error, %HTTPoison.Error{}}
         end
       ]}
    ]) do
      expected = {:error, "Something went wrong, please try again later"}
      assert expected == Coinjar.Coin.fetch_latest(:btc)
    end
  end
end
