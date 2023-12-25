defmodule ChuuniWeb.UserSessionController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  alias ChuuniWeb.UserAuth

  plug Hammer.Plug, [
    rate_limit: {"login", 60_000, 10}
  ] when action == :create

  def new(conn, _params) do
    if conn.assigns[:current_user] do
      conn
      |> put_view(html: UserAuthHTML)
      |> render(:must_be_logged_out)
    else
      render(conn, :new)
    end
  end

  def menu(conn, _params) do
    render(conn, :nav_menu)
  end

  def create(conn, %{"user" => user_params}) do
    if conn.assigns[:current_user] do
      conn
      |> put_view(html: UserAuthHTML)
      |> render(:must_be_logged_out)
    else
      %{"email" => email, "password" => password} = user_params

      if user = Accounts.get_user_by_email_and_password(email, password) do
        user_return_to = get_session(conn, :user_return_to)

        conn
        |> put_resp_header("hx-trigger", "login")
        |> put_resp_header("hx-location", ChuuniWeb.HTMXPlug.encode_hx_location(user_return_to || ~p"/"))
        |> UserAuth.log_in_user(user, user_params)
        |> put_view(ChuuniWeb.UserSettingsHTML)
        |> render(:success_message, message: "Welcome back!")
      else
        # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
        conn
        |> render(:log_in_form, error_message: "Invalid email or password")
      end
    end
  end

  def delete(conn, _params) do
    conn
    |> put_resp_header("hx-trigger", "logout")
    |> put_resp_header("hx-location", ChuuniWeb.HTMXPlug.encode_hx_location(~p"/"))
    |> UserAuth.log_out_user()
    |> render(:success_message, message: "Logged out successfully")
  end
end
