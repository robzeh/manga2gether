defmodule Manga2getherWeb.RoomLive.ReaderComponent do
  use Manga2getherWeb, :live_component

  alias Manga2gether.MangaDex
  alias Manga2gether.RoomServer

  def handle_event("search_manga", %{"search_manga" => %{"query" => query}} = _params, socket) do
    case MangaDex.search_manga(query) do
      {:ok, results} ->
        {:noreply,
         socket
         |> assign(:search_results, results)
         |> assign(:chapter_results, [])
         |> assign(:error, false)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:error, true)}
    end
  end

  def handle_event("get_chapters", %{"id" => manga_id, "title" => manga_title} = _params, socket) do
    case MangaDex.get_chapters_impl(manga_id, 0) do
      {:ok, results} ->
        {:noreply,
         socket
         |> assign(:chapter_results, results)
         |> assign(:manga_id, manga_id)
         |> assign(:manga_title, manga_title)
         |> assign(:error, false)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:error, true)}
    end
  end

  def handle_event("get_chapter", %{"id" => chapter_id} = _params, socket) do
    chapter = get_chapter_in_assigns(chapter_id, socket)

    # update room servers manga session
    {:ok, base_url} = MangaDex.get_server_impl(chapter.id)
    pages = MangaDex.construct_all_pages(base_url, "data", chapter.hash, chapter.data)

    manga = %{
      manga_title: socket.assigns.manga_title,
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
     |> assign(:search_results, [])
     |> assign(:error, false)}
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
