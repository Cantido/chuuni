defmodule ChuuniWeb.User.PasswordResetController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  import ChuuniWeb.UserAuth, only: [redirect_if_user_is_authenticated: 2]

  plug :redirect_if_user_is_authenticated

  def index(conn, _params) do
    render(conn, :index)
  end

  def send_reset_instructions(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/settings/password/reset/token/#{&1}")
      )
    end

    render(conn, :instruction_send_success)
  end

  def password_reset_form(conn, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      changeset = Accounts.change_user_password(user)
      conn
      |> render(:reset_password, changeset: changeset, token: token)
    else
      conn
      |> put_view(ChuuniWeb.UserSettingsHTML)
      |> render(:danger_message, message: "Reset password link is invalid or it has expired.")
    end
  end

  def update_password(conn, %{"token" => token, "user" => user_params}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      case Accounts.reset_user_password(user, user_params) do
        {:ok, _} ->
          conn
          |> put_view(ChuuniWeb.UserSettingsHTML)
          |> render(:success_message, message: "Password reset successfully.")

        {:error, changeset} ->
          conn
          |> render(:reset_password_form, changeset: changeset, token: token)
      end
    else
      conn
      |> put_view(ChuuniWeb.UserSettingsHTML)
      |> render(:danger_message, message: "Reset password link is invalid or it has expired.")
    end
  end
end
