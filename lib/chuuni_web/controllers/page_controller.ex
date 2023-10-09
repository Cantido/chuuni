defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

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

  def top(conn, _params) do
    conn
    |> render(:top)
  end
end
