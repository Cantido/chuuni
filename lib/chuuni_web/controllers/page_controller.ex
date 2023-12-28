defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

  alias Chuuni.Media
  alias Chuuni.Reviews

  require Logger

  plug :put_layout, html: {ChuuniWeb.Layouts, :app}

  def home(conn, _params) do
    new_anime = Media.new_anime(6)
      |> Enum.map(fn anime ->
        summary = Reviews.get_rating_summary(anime.id)
        if is_nil(summary) do
          %{count: 0, rating: nil, anime: anime}
        else
          %{summary | anime: anime}
        end
      end)

    trending = Reviews.trending(6)

    Logger.debug("new anime: #{inspect new_anime}")
    Logger.debug("trending anime: #{inspect trending}")

    conn
    |> render(:home, new_anime: new_anime, trending: trending)
  end

  def search(conn, _params) do
    conn
    |> render(:search)
  end

  def perform_search(conn, %{"query" => query}) do
    local_results = Media.search_anime(query)
    anilist_results = Media.search_anilist(query)

    conn
    |> put_layout(html: false)
    |> render(:search, query: query, local_results: local_results, anilist_results: anilist_results, current_user: conn.assigns[:current_user])
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
