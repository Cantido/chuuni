defmodule ChuuniWeb.UserFollowController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts

  def follower_count(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      follower_count = Accounts.get_follower_count(user)

      conn
      |> render(
        :follower_count,
        user: user,
        follower_count: follower_count
      )
    end
  end

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

  def follow(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      Accounts.follow(conn.assigns.current_user, user)

      conn
      |> put_resp_header("hx-trigger", "follow")
      |> render(:unfollow_button, user: user)
    end
  end

  def unfollow(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      Accounts.unfollow(conn.assigns.current_user, user)

      conn
      |> put_resp_header("hx-trigger", "unfollow")
      |> render(:follow_button, user: user)
    end
  end
end
