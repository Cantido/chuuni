defmodule ChuuniWeb.UserProfileController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews
  alias Chuuni.Accounts

  def profile(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)
      |> Chuuni.Repo.preload(shelves: :items)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      recent_reviews = Reviews.recent_for_user(user)

      follower_count = Accounts.get_follower_count(user)
      following_count = Accounts.get_following_count(user)


      average_rating = Reviews.average_rating(user)
      rating_count = Reviews.get_user_review_count(user)

      is_following? = if conn.assigns[:current_user], do: Accounts.following?(conn.assigns.current_user, user)
      similarity = if conn.assigns[:current_user], do: Reviews.similarity(conn.assigns.current_user, user)

      conn
      |> render(
        :profile,
        user: user,
        average_rating: average_rating,
        similarity: similarity,
        rating_count: rating_count,
        recent: recent_reviews,
        follower_count: follower_count,
        following_count: following_count,
        is_following?: is_following?
      )
    end
  end

  def activity(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)
      |> Chuuni.Repo.preload(shelves: :items)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      recent_reviews =
        Reviews.recent_for_user(user)
        |> Chuuni.Repo.preload(:author)

      conn
      |> render(
        :activity,
        user: user,
        recent: recent_reviews
      )
    end
  end

  def alltime(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)
      |> Chuuni.Repo.preload(shelves: :items)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      top_ten = Reviews.top_for_user(user)

      conn
      |> render(
        :all_time,
        user: user,
        top_ten: top_ten
      )
    end
  end
end
