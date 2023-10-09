defmodule ChuuniWeb.UserForgotPasswordTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  alias Chuuni.Accounts
  alias Chuuni.Repo

  describe "Forgot password page" do
    test "renders page", %{conn: conn} do
      conn = get(conn, ~p"/users/reset_password")

      assert html_response(conn, 200) =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/users/reset_password")

      assert redirected_to(conn) =~ "/"
    end
  end

  describe "Reset link" do
    setup do
      %{user: user_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/users/reset_password/send_instructions", user: %{"email" => user.email})

      assert html_response(conn, 200) =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users/reset_password/send_instructions", user: %{"email" => "unknown@example.com"})

      assert html_response(conn, 200) =~ "If your email is in our system"
      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
