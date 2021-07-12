defmodule Manga2getherWeb.DashboardLive.SearchComponent do
  use Manga2getherWeb, :live_component

  def handle_event("filter_search", %{"home_search" => %{"query" => query}} = _params, socket) do
    # show results if there is input
    val =
      if query == "" do
        nil
      else
        true
      end

    {:noreply,
     socket
     |> assign(:query, val)}
  end
end
