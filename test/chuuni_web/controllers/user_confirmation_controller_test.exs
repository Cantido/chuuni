defmodule ChuuniWeb.UserConfirmationLiveTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  alias Chuuni.Accounts
  alias Chuuni.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm/some-token")
      assert html_response(conn, 200) =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      conn = post(conn, ~p"/users/confirm", token: token)

      assert html_response(conn, 200) =~ "Your account has been confirmed!"

      assert Accounts.get_user!(user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) == []

      # when not logged in
      conn = post(conn, ~p"/users/confirm", token: "token")

      assert html_response(conn, 200) =~ "User confirmation link is invalid or it has expired"
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/users/confirm", token: "invalid-token")

      assert html_response(conn, 200) =~ "User confirmation link is invalid or it has expired"
      refute Accounts.get_user!(user.id).confirmed_at
    end
  end
end
