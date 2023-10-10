defmodule ChuuniWeb.UserProfileController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews
  alias Chuuni.Accounts

  def profile(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      top_ten = Reviews.top_for_user(user)
      recent_reviews = Reviews.recent_for_user(user)

      conn
      |> render(:profile, page_title: user.name, user: user, top_ten: top_ten, recent: recent_reviews)
    end
  end
end
