defmodule ChuuniWeb.UserResetPasswordTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  alias Chuuni.Accounts

  setup do
    user = user_fixture()

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_reset_password_instructions(user, url)
      end)

    %{token: token, user: user}
  end

  describe "Reset password page" do
    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, ~p"/users/reset_password/token/#{token}")

      assert html_response(conn, 200) =~ "Reset Password"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, ~p"/users/reset_password/token/invalid")

      assert html_response(conn, 200) =~ "Reset password link is invalid or it has expired."
    end

    test "renders errors for invalid data", %{conn: conn, token: token} do
      conn = post(conn, ~p"/users/reset_password/update", token: token, user: %{"password" => "secret12", "confirmation_password" => "secret123456"})

      assert html_response(conn, 200) =~ "should be at least 12 character"
      # assert html_response(conn, 200) =~ "does not match password"
    end
  end

  describe "Reset Password" do
    test "resets password once", %{conn: conn, token: token, user: user} do
      conn =
        conn
        |> post(~p"/users/reset_password/update",
        token: token,
        user: %{
          "password" => "new valid password",
          "password_confirmation" => "new valid password"
        })

      assert html_response(conn, 200) =~ "Password reset successfully"
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        conn
        |> post(~p"/users/reset_password/update",
        token: token,
        user: %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        )

      assert html_response(conn, 200) =~ "Reset Password"
      assert html_response(conn, 200) =~ "should be at least 12 character(s)"
      #assert html_response(conn, 200) =~ "does not match password"
    end
  end
end
