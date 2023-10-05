defmodule Chuuni.ReviewsTest do
  use Chuuni.DataCase

  alias Chuuni.Reviews

  describe "reviews" do
    alias Chuuni.Reviews.Review

    import Chuuni.AccountsFixtures
    import Chuuni.ReviewsFixtures
    import Chuuni.MediaFixtures

    @invalid_attrs %{rating: 12}

    setup do
      author = user_fixture()
      anime = anime_fixture()
      %{author: author, anime: anime}
    end

    test "top_rated/0 returns best rated" do
      worse_show = anime_fixture()
      better_show = anime_fixture()
      [
        %{rating: "1", anime_id: worse_show.id, author_id: user_fixture().id},
        %{rating: "2", anime_id: worse_show.id, author_id: user_fixture().id},
        %{rating: "3", anime_id: better_show.id, author_id: user_fixture().id},
        %{rating: "4", anime_id: better_show.id, author_id: user_fixture().id},
      ]
      |> Enum.each(fn attrs ->
        {:ok, _rating} = Reviews.create_review(attrs)
      end)

      top_rated = Reviews.top_rated()

      assert Enum.count(top_rated) == 2

      [first, second] = top_rated

      assert first.anime.id == better_show.id
      assert first[:rating] == Decimal.new("3.5000000000000000")
      assert first[:count] == 2
      assert second.anime.id == worse_show.id
      assert second[:rating] == Decimal.new("1.5000000000000000")
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

    test "create_review/1 with valid data creates a review", %{author: author, anime: anime} do
      valid_attrs = %{rating: 5, body: "some body", author_id: author.id, anime_id: anime.id}

      assert {:ok, %Review{} = review} = Reviews.create_review(valid_attrs)
      assert review.body == "some body"
      assert review.anime_id == anime.id
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()
      update_attrs = %{rating: 9, body: "some updated body"}

      assert {:ok, %Review{} = review} = Reviews.update_review(review, update_attrs)
      assert review.rating == 9
      assert review.body == "some updated body"
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
