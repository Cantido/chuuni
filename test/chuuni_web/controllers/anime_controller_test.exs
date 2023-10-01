defmodule ChuuniWeb.AnimeControllerTest do
  use ChuuniWeb.ConnCase

  import Chuuni.MediaFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all anime", %{conn: conn} do
      conn = get(conn, ~p"/anime")
      assert html_response(conn, 200) =~ "Listing Anime"
    end
  end

  describe "new anime" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/anime/new")
      assert html_response(conn, 200) =~ "New Anime"
    end
  end

  describe "create anime" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/anime", anime: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/anime/#{id}"

      conn = get(conn, ~p"/anime/#{id}")
      assert html_response(conn, 200) =~ "Anime #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/anime", anime: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Anime"
    end
  end

  describe "edit anime" do
    setup [:create_anime]

    test "renders form for editing chosen anime", %{conn: conn, anime: anime} do
      conn = get(conn, ~p"/anime/#{anime}/edit")
      assert html_response(conn, 200) =~ "Edit Anime"
    end
  end

  describe "update anime" do
    setup [:create_anime]

    test "redirects when data is valid", %{conn: conn, anime: anime} do
      conn = put(conn, ~p"/anime/#{anime}", anime: @update_attrs)
      assert redirected_to(conn) == ~p"/anime/#{anime}"

      conn = get(conn, ~p"/anime/#{anime}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, anime: anime} do
      conn = put(conn, ~p"/anime/#{anime}", anime: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Anime"
    end
  end

  describe "delete anime" do
    setup [:create_anime]

    test "deletes chosen anime", %{conn: conn, anime: anime} do
      conn = delete(conn, ~p"/anime/#{anime}")
      assert redirected_to(conn) == ~p"/anime"

      assert_error_sent 404, fn ->
        get(conn, ~p"/anime/#{anime}")
      end
    end
  end

  defp create_anime(_) do
    anime = anime_fixture()
    %{anime: anime}
  end
end
