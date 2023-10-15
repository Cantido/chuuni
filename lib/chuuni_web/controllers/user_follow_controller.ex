defmodule ChuuniWeb.UserFollowController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts

  def list_followers(conn, %{"username" => username}) do
    user = Accounts.get_user_by_name(username)

    if user do
      followers = Accounts.get_followers(user)

      conn
      |> render(:followers, followers: followers)
    else
      resp(conn, 404, "Not found")
    end
  end
end
