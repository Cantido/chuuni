defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

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
end
