defmodule ChuuniWeb.UserSessionControllerTest do
  use ChuuniWeb.ConnCase, async: true

  import Chuuni.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert get_resp_header(conn, "hx-location") == [~p"/"]

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Chuuni"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_chuuni_web_user_remember_me"]
      assert get_resp_header(conn, "hx-location") == [~p"/"]
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert get_resp_header(conn, "hx-location") == ["/foo/bar"]
      assert html_response(conn, 200) =~ "Welcome back!"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert html_response(conn, 200) =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert get_resp_header(conn, "hx-location") == [~p"/"]
      refute get_session(conn, :user_token)
      assert html_response(conn, 200) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert get_resp_header(conn, "hx-location") == [~p"/"]
      refute get_session(conn, :user_token)
      assert html_response(conn, 200) =~ "Logged out successfully"
    end
  end
end
