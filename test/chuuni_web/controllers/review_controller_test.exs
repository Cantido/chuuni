defmodule ChuuniWeb.ReviewControllerTest do
  use ChuuniWeb.ConnCase

  import Chuuni.ReviewsFixtures

  @create_attrs %{body: "some body", item_reviewed: "some item_reviewed"}
  @update_attrs %{body: "some updated body", item_reviewed: "some updated item_reviewed"}
  @invalid_attrs %{body: nil, item_reviewed: nil}

  setup :register_and_log_in_user

  describe "index" do
    test "lists all reviews", %{conn: conn} do
      conn = get(conn, ~p"/reviews")
      assert html_response(conn, 200) =~ "Listing Reviews"
    end
  end

  describe "new review" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/reviews/new")
      assert html_response(conn, 200) =~ "New Review"
    end
  end

  describe "create review" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/reviews", review: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/reviews/#{id}"

      conn = get(conn, ~p"/reviews/#{id}")
      assert html_response(conn, 200) =~ @create_attrs[:body]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/reviews", review: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Review"
    end
  end

  describe "edit review" do
    setup [:create_review]

    test "renders form for editing chosen review", %{conn: conn, review: review} do
      conn = get(conn, ~p"/reviews/#{review}/edit")
      assert html_response(conn, 200) =~ "Edit Review"
    end
  end

  describe "update review" do
    setup [:create_review]

    test "redirects when data is valid", %{conn: conn, review: review} do
      conn = put(conn, ~p"/reviews/#{review}", review: @update_attrs)
      assert redirected_to(conn) == ~p"/reviews/#{review}"

      conn = get(conn, ~p"/reviews/#{review}")
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, review: review} do
      conn = put(conn, ~p"/reviews/#{review}", review: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Review"
    end
  end

  describe "delete review" do
    setup [:create_review]

    test "deletes chosen review", %{conn: conn, review: review} do
      conn = delete(conn, ~p"/reviews/#{review}")
      assert redirected_to(conn) == ~p"/reviews"

      assert_error_sent 404, fn ->
        get(conn, ~p"/reviews/#{review}")
      end
    end
  end

  defp create_review(_) do
    review = review_fixture()
    %{review: review}
  end
end
