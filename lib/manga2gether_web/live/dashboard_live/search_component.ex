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

    # filter results
    filtered_results =
      Enum.filter(
        socket.assigns.rooms,
        fn room ->
          current_manga =
            if room.current_manga == nil do
              ""
            else
              room.current_manga
            end

          # show room if name, owners name, current manga or room code contain query value
          String.downcase(room.name) =~ String.downcase(query) ||
            String.downcase(room.user.username) =~ String.downcase(query) ||
            String.downcase(current_manga) =~ String.downcase(query) ||
            Integer.to_string(room.room_code) == String.downcase(query)
        end
      )

    {:noreply,
     socket
     |> assign(:query, val)
     |> assign(:results, filtered_results)}
  end

  def handle_event("join_room", %{"code" => room_code} = _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.room_show_path(socket, :show, room_code))}
  end
end
