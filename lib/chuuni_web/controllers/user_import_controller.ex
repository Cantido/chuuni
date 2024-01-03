defmodule ChuuniWeb.UserImportController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts.MyanimelistImportWorker

  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]

  require Logger

  plug :require_authenticated_user

  def index(conn, _params) do
    render(conn, :index)
  end

  def import_mal(conn, %{"mal_username" => username}) do
    if username =~ ~r/^[a-zA-Z0-9]{2,16}$/ do
      MyanimelistImportWorker.new(%{user_id: conn.assigns.current_user.id, mal_username: username})
      |> Oban.insert()

      render(conn, :mal_form, success_message: "Your lists are now being imported!")
    else
      render(conn, :mal_form, danger_message: "Invalid username!")
    end
  end
end
