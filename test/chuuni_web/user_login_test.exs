defmodule ChuuniWeb.UserLoginTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, ~p"/users/log_in")

      assert html_response(conn, 200) =~ "Sign in to account"
      assert html_response(conn, 200) =~ "Sign up"
      assert html_response(conn, 200) =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/users/log_in")

      assert redirected_to(conn)
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      password = "123456789abcd"
      user = user_fixture(%{password: password})

      conn = post(conn, ~p"/users/log_in", user: %{email: user.email, password: password, remember_me: true})

      assert html_response(conn, 200) =~ "Welcome back!"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      conn = post(conn, ~p"/users/log_in", user: %{email: "asdf@asdf.com", password: "1234567890abcd"})

      assert html_response(conn, 200) =~ "Invalid email or password"
    end
  end
end
