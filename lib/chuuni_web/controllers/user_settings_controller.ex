defmodule ChuuniWeb.UserSettingsController do
  use ChuuniWeb, :controller

  alias ChuuniWeb.UserAuth
  alias Chuuni.Accounts

  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]

  plug :require_authenticated_user

  def edit(conn, _params) do
    user = conn.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    render(conn, :edit, email_changeset: email_changeset, password_changeset: password_changeset)
  end

  def edit_email(conn, _params) do
    user = conn.assigns.current_user
    email_changeset = Accounts.change_user_email(user)

    render(conn, :email_form, email_changeset: email_changeset)
  end

  def update_email(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, user_params["current_password"], user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/settings/email/confirm/#{&1}")
        )

        conn
        |> render(:success_message,
          message: "A link to confirm your email change has been sent to the new address.",
          close_url: ~p"/settings/email"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render(:email_form, email_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        render(conn, :success_message, message: "Email changed successfully.")

      :error ->
        render(conn, :danger_message, message: "Email change link is invalid or it has expired.")
    end
  end

  def update_password(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, user_params["current_password"], user_params) do
      {:ok, _user} ->
        conn
        |> UserAuth.log_out_user()
        |> put_resp_header("hx-trigger", "logout")
        |> put_resp_header("hx-location", ~p"/")
        |> render(:success_message,
          message: "You changed your password. You are now being logged out.")

      {:error, changeset} ->
        render(conn, :password_form, password_changeset: changeset)
    end
  end
end
