defmodule Manga2getherWeb.RoomLive.ReaderComponent do
  use Manga2getherWeb, :live_component

  alias Manga2gether.MangaDex
  alias Manga2gether.RoomServer

  def preload(list_of_assigns) do
    IO.inspect(list_of_assigns)

    Enum.map(list_of_assigns, fn assigns ->
      IO.inspect(assigns.room_code)
      Map.put(assigns, :room_code, assigns.room_code)
    end)
  end

  def mount(socket) do
    IO.inspect(socket.assigns)
    {:ok, socket}
  end

  ################################################################################

  def handle_info(%{event: "set_manga", payload: %{manga: new_manga}} = _message, socket) do
    IO.inspect(new_manga)

    {:noreply,
     socket
     |> assign(:manga, new_manga)}
  end

  def handle_info(%{event: "next_manga_page", payload: %{manga: new_manga}} = _message, socket) do
    IO.inspect(new_manga)

    {:noreply,
     socket
     |> assign(:current_page, new_manga.current_page)}
  end

  ################################################################################

  def handle_event("search_manga", %{"search_manga" => %{"query" => query}} = _params, socket) do
    case MangaDex.search_manga(query) do
      {:ok, results} ->
        {:noreply,
         socket
         |> assign(:search_results, results)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("get_chapters", %{"id" => manga_id} = _params, socket) do
    case MangaDex.get_chapters_impl(manga_id, 0) do
      {:ok, results} ->
        {:noreply,
         socket
         |> assign(:chapter_results, results)
         |> assign(:manga_id, manga_id)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("get_chapter", %{"id" => chapter_id} = _params, socket) do
    chapter = get_chapter_in_assigns(chapter_id, socket)

    # update room servers manga session
    {:ok, base_url} = MangaDex.get_server_impl(chapter.id)
    pages = MangaDex.construct_all_pages(base_url, "data", chapter.hash, chapter.data)

    manga = %{
      title: chapter.title,
      pages: pages,
      current_page: hd(pages)
    }

    RoomServer.set_manga(socket.assigns.room_code, manga)
    RoomServer.set_reading(socket.assigns.room_code, true)

    # clear results
    {:noreply,
     socket
     |> assign(:chapter_results, [])
     |> assign(:search_results, [])}
  end

  def handle_event("load_more", %{"id" => manga_id} = _params, socket) do
    case MangaDex.get_chapters_impl(manga_id, length(socket.assigns.chapter_results)) do
      {:ok, results} ->
        {:noreply,
         socket
         |> assign(:chapter_results, socket.assigns.chapter_results ++ results)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  # def handle_event("next_page", params, socket) do
  #   IO.inspect("params")
  #   IO.inspect(params)
  #   {:noreply, socket}
  # end

  def update(assigns, socket) do
    IO.inspect(socket)
    {:ok, assign(socket, assigns)}
  end

  defp get_chapter_in_assigns(chapter_id, socket) do
    try do
      for chapter <- socket.assigns.chapter_results do
        if chapter.id == chapter_id, do: throw({:break, chapter}), else: chapter
      end
    catch
      {:break, chapter} -> chapter
    end
  end
end
