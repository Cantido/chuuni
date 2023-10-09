defmodule ChuuniWeb.UserRegistrationControllerTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, ~p"/users/register")

      assert html_response(conn, 200) =~ "Register"
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/users/register")

      assert redirected_to(conn) =~ ~p"/"
    end

    test "renders errors for invalid data", %{conn: conn} do
      conn = post(conn, ~p"/users/create", user: %{"email" => "with spaces", "password" => "too short"})

      assert html_response(conn, 200) =~ "Register"
      assert html_response(conn, 200) =~ "must have the @ sign and no spaces"
      assert html_response(conn, 200) =~ "should be at least 12 character"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      conn = post(conn, ~p"/users/create", user: valid_user_attributes(email: unique_user_email()))

      assert html_response(conn, 200) =~ "Your new account has been created! Please log in."

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      refute response =~ "Register"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      user = user_fixture(%{email: "test@email.com"})

      conn = post(conn, ~p"/users/create", user: valid_user_attributes(email: user.email))

      assert html_response(conn, 200) =~ "has already been taken"
    end
  end
end
