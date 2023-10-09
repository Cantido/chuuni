defmodule ChuuniWeb.UserConfirmationInstructionsLiveTest do
  use ChuuniWeb.ConnCase

  import Chuuni.AccountsFixtures

  alias Chuuni.Accounts
  alias Chuuni.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Resend confirmation" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/users/confirm")
      assert html_response(conn, 200) =~ "Resend confirmation instructions"
    end

    test "sends a new confirmation token", %{conn: conn, user: user} do
      conn = post(conn, ~p"/users/confirm/send", email: user.email)

      assert html_response(conn, 200) =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if user is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      conn = post(conn, ~p"/users/confirm/send", email: user.email)

      assert html_response(conn, 200) =~ "If your email is in our system"

      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users/confirm/send", email: "unknown@example.com")

      assert html_response(conn, 200) =~ "If your email is in our system"

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
