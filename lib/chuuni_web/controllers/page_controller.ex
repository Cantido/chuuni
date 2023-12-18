defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

  alias Chuuni.Media
  alias Chuuni.Reviews

  plug :put_layout, html: {ChuuniWeb.Layouts, :app}

  def home(conn, _params) do
    new_anime = Media.new_anime(6)
      |> Enum.map(fn anime ->
        summary = Reviews.get_rating_summary(anime.id)|> Chuuni.Repo.preload(:anime)
        %{summary: summary}
      end)

    top_anime = Reviews.top_rated(6)

    conn
    |> assign(:page_title, "Welcome")
    |> render(:home, new_anime: new_anime, top_anime: top_anime)
  end

  def search(conn, _params) do
    conn
    |> assign(:page_title, "Search")
    |> render(:search)
  end

  def perform_search(conn, %{"query" => query}) do
    local_results = Media.search_anime(query)
    anilist_results = Media.search_anilist(query)

    conn
    |> put_layout(html: false)
    |> render(:search, query: query, local_results: local_results, anilist_results: anilist_results)
  end

  def search_results(conn, %{"query" => query}) do
    local_results = Media.search_anime(query)
    anilist_results = Media.search_anilist(query)

    conn
    |> put_layout(html: false)
    |> put_view(html: ChuuniWeb.AnimeHTML)
    |> render(:search_results, local_results: local_results, anilist_results: anilist_results)
  end

  def top(conn, _params) do
    reviews = Reviews.top_rated()

    conn
    |> render(:top, reviews: reviews)
  end
end
