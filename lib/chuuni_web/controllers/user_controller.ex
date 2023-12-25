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

  def create(conn, %{"user" => user_params} = params) do
    if hcaptcha_success?(params["h-captcha-response"], :inet.ntoa(conn.remote_ip)) do
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
    else
      conn
      |> put_view(ChuuniWeb.UserSessionHTML)
      |> render(:log_in_form, error_message: "Captcha failed")
    end
  end

  defp hcaptcha_success?(captcha_response, remote_ip) do
    if ChuuniWeb.captcha_enabled?() do
      HTTPoison.post!(
        "https://api.hcaptcha.com/siteverify",
        {:form, [
          {"response", captcha_response},
          {"secret", Application.get_env(:chuuni, :hcaptcha) |> Keyword.get(:secret)},
          {"remoteip", remote_ip},
          {"sitekey", Application.get_env(:chuuni, :hcaptcha) |> Keyword.get(:sitekey)}
        ]}
      )
      |> then(fn resp ->
        Jason.decode!(resp.body)
      end)
      |> Keyword.get("success", false)
    else
      true
    end
  end
end
