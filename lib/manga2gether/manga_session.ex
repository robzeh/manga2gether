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
end
