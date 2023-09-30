defmodule Chuuni.ReviewsTest do
  use Chuuni.DataCase

  alias Chuuni.Reviews

  describe "ratings" do
    alias Chuuni.Reviews.Rating

    import Chuuni.ReviewsFixtures
    import Chuuni.AccountsFixtures

    @invalid_attrs %{value: "11", author_id: "5a1df0a7-c80f-4b91-8c18-e913cd4d58de"}

    setup do
      author = user_fixture()
      %{author: author}
    end

    test "list_ratings/0 returns all ratings" do
      rating = rating_fixture()
      [actual_rating] = Reviews.list_ratings()

      assert rating.id == actual_rating.id
    end

    test "get_rating!/1 returns the rating with given id" do
      rating = rating_fixture()
      assert Reviews.get_rating!(rating.id).id == rating.id
    end

    test "create_rating/1 with valid data creates a rating", %{author: author} do
      valid_attrs = %{value: "5", item_rated: "some item_rated", author_id: author.id}

      assert {:ok, %Rating{} = rating} = Reviews.create_rating(valid_attrs)
      assert rating.value == Decimal.new("5")
      assert rating.value_worst == Decimal.new("1")
      assert rating.value_best == Decimal.new("10")
      assert rating.author_id == author.id
    end

    test "create_rating/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_rating(@invalid_attrs)
    end

    test "update_rating/2 with valid data updates the rating" do
      rating = rating_fixture()
      update_attrs = %{value: "7"}

      assert {:ok, %Rating{} = rating} = Reviews.update_rating(rating, update_attrs)
      assert rating.value == Decimal.new("7")
    end

    test "update_rating/2 with invalid data returns error changeset" do
      rating = rating_fixture()
      assert {:error, %Ecto.Changeset{}} = Reviews.update_rating(rating, @invalid_attrs)
      assert rating.value == Reviews.get_rating!(rating.id).value
    end

    test "delete_rating/1 deletes the rating" do
      rating = rating_fixture()
      assert {:ok, %Rating{}} = Reviews.delete_rating(rating)
      assert_raise Ecto.NoResultsError, fn -> Reviews.get_rating!(rating.id) end
    end

    test "change_rating/1 returns a rating changeset" do
      rating = rating_fixture()
      assert %Ecto.Changeset{} = Reviews.change_rating(rating)
    end
  end

  describe "reviews" do
    alias Chuuni.Reviews.Review

    import Chuuni.AccountsFixtures
    import Chuuni.ReviewsFixtures

    @invalid_attrs %{body: nil, item_reviewed: nil}

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
      valid_attrs = %{body: "some body", item_reviewed: "some item_reviewed", author_id: author.id}

      assert {:ok, %Review{} = review} = Reviews.create_review(valid_attrs)
      assert review.body == "some body"
      assert review.item_reviewed == "some item_reviewed"
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()
      update_attrs = %{body: "some updated body", item_reviewed: "some updated item_reviewed"}

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
