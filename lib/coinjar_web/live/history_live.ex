defmodule CoinjarWeb.HistoryLive do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_view
  use Phoenix.LiveView
  require Logger

  def render(assigns) do
    ## Should also be in it's own page
    ~L"""
    <div> <table> <tr>
      <td> coin </td>
      <td> ask </td>
      <td> bid </td>
      <td> last </td>
      <td> inserted_at </td>
    </tr>
    <%= Enum.map @historical, fn coin -> %>
    <tr>
      <td> <%= coin.coin %> </td>
      <td> <%= coin.ask %> </td>
      <td> <%= coin.bid %> </td>
      <td> <%= coin.last %> </td>
      <td> <%= coin.inserted_at %> </td>
    </tr>
    <%= end %>
    </table>
    <button phx-click="back"> back </button>
    """
  end

  def handle_event("back", _value, socket) do
    {:noreply, push_redirect(socket, to: "/")}
  end

  def mount(_params, _session, socket) do
    # Trigger latest price on refresh, inefficent as every refresh triggers another call
    # Need to look into hydrating page state

    saved = Coinjar.Coin.fetch_saved()

    {:ok, assign(socket, :historical, saved)}
  end

  def handle_info(_coin, socket) do
    ## Handles subscribe ticks
    {:noreply, socket}
  end
end
