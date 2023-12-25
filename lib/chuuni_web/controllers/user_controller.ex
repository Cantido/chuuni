defmodule ChuuniWeb.UserController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  alias Chuuni.Accounts.User

  import ChuuniWeb.UserAuth, only: [redirect_if_user_is_authenticated: 2]

  plug :redirect_if_user_is_authenticated

  plug Hammer.Plug, [
    rate_limit: {"user:create", 60_000, 5}
  ] when action == :create

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
            &url(~p"/settings/confirm/#{&1}")
          )

        conn
        |> put_view(ChuuniWeb.UserSessionHTML)
        |> render(:log_in_form, success_message: "Your new account has been created! Please log in.")
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :register, changeset: changeset)
    end
  end
end
