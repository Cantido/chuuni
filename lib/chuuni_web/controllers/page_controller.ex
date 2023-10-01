defmodule ChuuniWeb.PageController do
  use ChuuniWeb, :controller

  def home(conn, _params) do
    conn
    |> assign(:page_title, "Welcome")
    |> render(:home)
  end
end
