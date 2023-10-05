defmodule Chuuni.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chuuni.Reviews` context.
  """

  import Chuuni.AccountsFixtures
  import Chuuni.MediaFixtures

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        rating: 5,
        body: "some body",
        item_reviewed: "some item_reviewed",
        author_id: user_fixture().id,
        anime_id: anime_fixture().id
      })
      |> Chuuni.Reviews.create_review()

    review
  end
end
