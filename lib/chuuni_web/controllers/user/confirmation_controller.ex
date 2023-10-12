defmodule ChuuniWeb.User.ConfirmationController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts

  def send_confirm_email(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/settings/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    conn
    |> put_view(html: ChuuniWeb.UserHTML)
    |> render(:success_message, message: info)
  end

  def confirm_form(conn, %{"token" => token}) do
    render(conn, :confirm_form, token: token)
  end

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _user} ->
        conn
        |> put_view(html: ChuuniWeb.UserHTML)
        |> render(:success_message, message: "Your account has been confirmed! Please log in.")
      :error ->
        conn
        |> put_view(html: ChuuniWeb.UserHTML)
        |> render(:error_message, message: "User confirmation link is invalid or it has expired.")
    end
  end

  def confirmation_instructions(conn, _params) do
    conn
    |> put_view(html: ChuuniWeb.UserHTML)
    |> render(:confirmation_instructions)
  end
end
