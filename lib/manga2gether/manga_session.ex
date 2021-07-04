defmodule Manga2gether.MangaSession do
  defstruct title: nil,
            pages: [],
            current_idx: 0,
            current_page: nil

  @type t :: %__MODULE__{
          title: String.t(),
          pages: list(String.t()),
          current_idx: integer(),
          current_page: String.t()
        }

  @spec new(map()) :: t()
  def new(manga) do
    struct!(__MODULE__, manga)
  end

  def next_page(manga) do
    if manga.current_idx + 1 < length(manga.pages),
      do: %{
        manga
        | current_idx: manga.current_idx + 1,
          current_page: Enum.at(manga.pages, manga.current_idx + 1)
      }
  end
end
