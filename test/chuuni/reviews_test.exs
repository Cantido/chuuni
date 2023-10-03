defmodule Chuuni.ReviewsTest do
  use Chuuni.DataCase

  alias Chuuni.Reviews

  describe "reviews" do
    alias Chuuni.Reviews.Review

    import Chuuni.AccountsFixtures
    import Chuuni.ReviewsFixtures

    @invalid_attrs %{body: nil, item_reviewed: nil}

    setup do
      author = user_fixture()
      %{author: author}
    end

    test "top_rated/0 returns best rated" do
      [
        %{rating: "1", item_reviewed: "worse show", author_id: user_fixture().id},
        %{rating: "2", item_reviewed: "worse show", author_id: user_fixture().id},
        %{rating: "3", item_reviewed: "better show", author_id: user_fixture().id},
        %{rating: "4", item_reviewed: "better show", author_id: user_fixture().id},
      ]
      |> Enum.each(fn attrs ->
        {:ok, _rating} = Reviews.create_review(attrs)
      end)

      top_rated = Reviews.top_rated()

      assert Enum.count(top_rated) == 2

      [first, second] = top_rated

      assert first[:item_reviewed] == "better show"
      assert first[:rating] == 3.5
      assert first[:count] == 2
      assert second[:item_reviewed] == "worse show"
      assert second[:value] == 1.5
      assert second[:count] == 2
    end

    test "list_reviews/0 returns all reviews" do
      review = review_fixture()
      assert Reviews.list_reviews() == [review]
    end

    test "get_review!/1 returns the review with given id" do
      review = review_fixture()
      assert Reviews.get_review!(review.id).id == review.id
    end

    test "create_review/1 with valid data creates a review" do
      author = user_fixture()
      valid_attrs = %{rating: 5, body: "some body", item_reviewed: "some item_reviewed", author_id: author.id}

      assert {:ok, %Review{} = review} = Reviews.create_review(valid_attrs)
      assert review.body == "some body"
      assert review.item_reviewed == "some item_reviewed"
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()
      update_attrs = %{rating: 5, body: "some updated body", item_reviewed: "some updated item_reviewed"}

      assert {:ok, %Review{} = review} = Reviews.update_review(review, update_attrs)
      assert review.body == "some updated body"
      assert review.item_reviewed == "some updated item_reviewed"
    end

    test "update_review/2 with invalid data returns error changeset" do
      review = review_fixture()
      assert {:error, %Ecto.Changeset{}} = Reviews.update_review(review, @invalid_attrs)
      assert review.body == Reviews.get_review!(review.id).body
    end

    test "delete_review/1 deletes the review" do
      review = review_fixture()
      assert {:ok, %Review{}} = Reviews.delete_review(review)
      assert_raise Ecto.NoResultsError, fn -> Reviews.get_review!(review.id) end
    end

    test "change_review/1 returns a review changeset" do
      review = review_fixture()
      assert %Ecto.Changeset{} = Reviews.change_review(review)
    end
  end
end
