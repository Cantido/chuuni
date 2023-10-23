defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

  alias Chuuni.Media

  plug :put_layout, html: {ChuuniWeb.Layouts, :app}

  def home(conn, _params) do
    conn
    |> assign(:page_title, "Welcome")
    |> render(:home)
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
    conn
    |> render(:top)
  end
end
