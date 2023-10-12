defmodule ChuuniWeb.ShelfControllerTest do
  use ChuuniWeb.ConnCase

  import Chuuni.ShelvesFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  describe "index" do
    test "lists all shelves", %{conn: conn} do
      conn = get(conn, ~p"/shelves")
      assert html_response(conn, 200) =~ "Listing Shelves"
    end
  end

  describe "new shelf" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shelves/new")
      assert html_response(conn, 200) =~ "New Shelf"
    end
  end

  describe "create shelf" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shelves", shelf: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shelves/#{id}"

      conn = get(conn, ~p"/shelves/#{id}")
      assert html_response(conn, 200) =~ "Shelf #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shelves", shelf: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shelf"
    end
  end

  describe "edit shelf" do
    setup [:create_shelf]

    test "renders form for editing chosen shelf", %{conn: conn, shelf: shelf} do
      conn = get(conn, ~p"/shelves/#{shelf}/edit")
      assert html_response(conn, 200) =~ "Edit Shelf"
    end
  end

  describe "update shelf" do
    setup [:create_shelf]

    test "redirects when data is valid", %{conn: conn, shelf: shelf} do
      conn = put(conn, ~p"/shelves/#{shelf}", shelf: @update_attrs)
      assert redirected_to(conn) == ~p"/shelves/#{shelf}"

      conn = get(conn, ~p"/shelves/#{shelf}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, shelf: shelf} do
      conn = put(conn, ~p"/shelves/#{shelf}", shelf: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Shelf"
    end
  end

  describe "delete shelf" do
    setup [:create_shelf]

    test "deletes chosen shelf", %{conn: conn, shelf: shelf} do
      conn = delete(conn, ~p"/shelves/#{shelf}")
      assert redirected_to(conn) == ~p"/shelves"

      assert_error_sent 404, fn ->
        get(conn, ~p"/shelves/#{shelf}")
      end
    end
  end

  defp create_shelf(_) do
    shelf = shelf_fixture()
    %{shelf: shelf}
  end
end
