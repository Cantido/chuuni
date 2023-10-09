defmodule ChuuniWeb.UserController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  alias Chuuni.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :register, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        conn
        |> put_view(ChuuniWeb.UserSessionHTML)
        |> render(:success_message, message: "Your new account has been created! Please log in.")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :register, changeset: changeset)
    end
  end

  def send_confirm_email(conn, %{"email" => email}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    render(conn, :success_message, message: info)
  end

  def confirm_form(conn, %{"token" => token}) do
    render(conn, :confirm_form, token: token)
  end

  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _user} ->
        conn
        |> render(:success_message, message: "Your account has been confirmed! Please log in.")
      :error ->
        conn
        |> render(:error_message, message: "User confirmation link is invalid or it has expired.")
    end
  end

  def confirmation_instructions(conn, _params) do
    render(conn, :confirmation_instructions)
  end
end
