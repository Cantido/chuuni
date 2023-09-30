defmodule Chuuni.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chuuni.Reviews` context.
  """

  import Chuuni.AccountsFixtures

  @doc """
  Generate a rating.
  """
  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        value: "5",
        item_rated: "some item_rated",
        author_id: user_fixture().id
      })
      |> Chuuni.Reviews.create_rating()

    rating
  end

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        body: "some body",
        item_reviewed: "some item_reviewed",
        author_id: user_fixture().id
      })
      |> Chuuni.Reviews.create_review()

    review
  end
end
