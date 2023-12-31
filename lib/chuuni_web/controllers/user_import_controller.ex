defmodule ChuuniWeb.UserImportController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts

  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]
  import Ecto.Query

  require Logger

  plug :require_authenticated_user

  def index(conn, _params) do
    render(conn, :index)
  end

  def import_mal(conn, %{"mal_username" => username}) do
    if username =~ ~r/^[a-zA-Z0-9]{2,16}$/ do

      Accounts.import_mal_profile(conn.assigns[:current_user], username)

      render(conn, :mal_form, success_message: "Your lists are now being imported!")
    else
      render(conn, :mal_form, danger_message: "Something went wrong!")
    end
  end
end
