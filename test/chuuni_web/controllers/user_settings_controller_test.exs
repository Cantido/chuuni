defmodule ChuuniWeb.UserSettingsControllerTest do
  use ChuuniWeb.ConnCase

  alias Chuuni.Accounts
  import Chuuni.AccountsFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      conn =
        conn
        |> log_in_user(user_fixture())
        |> get(~p"/users/settings")

      assert html_response(conn, 200) =~ "Change Email"
      assert html_response(conn, 200) =~ "Change Password"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      conn = get(conn, ~p"/users/settings")

      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "updates the user email", %{conn: conn, password: password, user: user} do
      new_email = unique_user_email()

      conn = post(conn, ~p"/users/settings/email", user: %{current_password: password, email: new_email})

      assert html_response(conn, 200) =~ "A link to confirm your email"
      assert Accounts.get_user_by_email(user.email)
    end

    test "renders errors with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/users/settings/email", user: %{current_password: "invalid", email: "with spaces"})

      assert html_response(conn, 400) =~ "Change Email"
      assert html_response(conn, 400) =~ "must have the @ sign and no spaces"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_user_password()
      user = user_fixture(%{password: password})
      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "updates the user password", %{conn: conn, user: user, password: password} do
      new_password = valid_user_password()

      conn = post(conn, ~p"/users/settings/password", user: %{
          "current_password" => password,
          "email" => user.email,
          "password" => new_password,
          "password_confirmation" => new_password
        })

      assert is_nil(get_session(conn, :user_token))

      assert html_response(conn, 200) =~ "You changed your password."

      assert Accounts.get_user_by_email_and_password(user.email, new_password)
    end

    test "renders errors with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/users/settings/password", user: %{
          "current_password" => "invalid",
          "password" => "too short",
          "password_confirmation" => "does not match"
        })

      assert html_response(conn, 200) =~ "Change Password"
      assert html_response(conn, 200) =~ "should be at least 12 character(s)"
      assert html_response(conn, 200) =~ "does not match password"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{conn: log_in_user(conn, user), token: token, email: email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")


      assert html_response(conn, 200) =~ "Email changed successfully."
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      # use confirm token again
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      assert html_response(conn, 200) =~ "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/settings/confirm_email/oops")
      assert html_response(conn, 200) =~ "Email change link is invalid or it has expired."
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, ~p"/users/settings/confirm_email/#{token}")
      assert redirected_to(conn) =~ ~p"/users/log_in"
    end
  end
end
