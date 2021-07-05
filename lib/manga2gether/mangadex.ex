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

  @spec get_chapters_impl(String.t(), integer()) :: {:error, any} | {:ok, list(map())}
  def get_chapters_impl(manga_id, offset \\ 0) do
    case get_chapters(manga_id, offset) do
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

  @spec get_server_impl(String.t()) :: {:error, any} | {:ok, String.t()}
  def get_server_impl(chapter_id) do
    case get_server(chapter_id) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        url =
          body
          |> parse_value("baseUrl")

        {:ok, url}

      {:ok, error} ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec construct_all_pages(String.t(), String.t(), String.t(), list(String.t())) ::
          list(String.t())
  def construct_all_pages(base_url, quality, hash, files) do
    Enum.map(files, fn file ->
      [base_url, "/", quality, "/", hash, "/", file]
    end)
  end

  ################################################################################
  ### HTTP Calls

  defp search(title, limit \\ 10) do
    get("/manga", query: [title: title, limit: limit])
  end

  defp get_chapters(manga_id, offset) do
    get("/chapter",
      query: [
        manga: manga_id,
        translatedLanguage: ["en"],
        order: [chapter: "desc"],
        offset: offset
      ]
    )
  end

  defp get_server(chapter_id) do
    get("/at-home/server/" <> chapter_id)
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
        description: result["data"]["attributes"]["description"]["en"],
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
        data_saver: result["data"]["attributes"]["dataSaver"],
        publish_at: result["data"]["attributes"]["publishAt"]
      }
    end)
  end
end
