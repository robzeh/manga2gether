defmodule Manga2gether.MangaDex do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.mangadex.org"
  plug Tesla.Middleware.JSON

  ################################################################################
  ### Implementations

  @spec search_manga(String.t()) :: {:error, any} | {:ok, list(map())}
  def search_manga(title) do
    case search(title) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        results =
          body
          |> parse_value("results")
          |> parse_search()

        {:ok, results}

      {:ok, error} ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_chapters_impl(String.t()) :: {:error, any} | {:ok, list(map())}
  def get_chapters_impl(manga_id) do
    case get_chapters(manga_id) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        results =
          body
          |> parse_value("results")
          |> parse_chapters()

        {:ok, results}

      {:ok, error} ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  ################################################################################
  ### HTTP Calls

  defp search(title, limit \\ 10) do
    get("/manga", query: [title: title, limit: limit])
  end

  defp get_chapters(manga_id) do
    get("/chapter", query: [manga: manga_id, translatedLanguage: ["en"]])
  end

  ################################################################################
  ### Utilities

  defp parse_value(map, key), do: Map.get(map, key)

  @spec parse_search(map()) :: list(map())
  defp parse_search(results) do
    Enum.map(results, fn result ->
      %{
        id: result["data"]["id"],
        title: result["data"]["attributes"]["title"]["en"],
        description: result["data"]["attributes"]["description"],
        last_chapter: result["data"]["attributes"]["lastChapter"],
        updated_at: result["data"]["attributes"]["updatedAt"],
        last_volume: result["data"]["attributes"]["lastVolume"]
      }
    end)
  end

  defp parse_chapters(results) do
    Enum.map(results, fn result ->
      %{
        id: result["data"]["id"],
        title: result["data"]["attributes"]["title"],
        volume: result["data"]["attributes"]["volume"],
        chapter: result["data"]["attributes"]["chapter"],
        hash: result["data"]["attributes"]["hash"],
        data: result["data"]["attributes"]["data"],
        dataSaver: result["data"]["attributes"]["dataSaver"],
        publishAt: result["data"]["attributes"]["publishAt"]
      }
    end)
  end
end
