defmodule ChuuniWeb.UserProfileController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts

  def profile(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)

    if is_nil(user) do
      conn
      |> put_status(:not_found)
      |> put_view(ChuuniWeb.ErrorHTML)
      |> render(:"404")
    else
      conn
      |> render(:profile, page_title: user.name, user: user)
    end
  end
end
