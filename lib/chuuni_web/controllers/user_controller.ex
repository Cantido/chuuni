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
        |> render(:log_in_form, success_message: "Your new account has been created! Please log in.")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :register, changeset: changeset)
    end
  end
end
