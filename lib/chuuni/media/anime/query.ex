defmodule Chuuni.Media.Anime.Query do
  import Ecto.Query

  alias Chuuni.Media.Anime

  def search(query) do
    db_search_term = "%" <> query <> "%"

    from a in Anime,
    where: ilike(type(a.title["english"], :string), ^db_search_term)
        or ilike(type(a.title["romaji"], :string), ^db_search_term)
        or ilike(type(a.title["native"], :string), ^db_search_term)
        or ilike(type(a.external_ids["anilist"], :string), ^db_search_term)
  end
end
