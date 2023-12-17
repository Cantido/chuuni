defmodule Chuuni.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Reviews.ReviewQueries
  alias Chuuni.Repo

  alias Chuuni.Accounts.User
  alias Chuuni.Reviews.Review
  alias Chuuni.Shelves.Shelf

  def top_rated(limit \\ 10) do
    top_rated =
      ReviewQueries.review_summary()
      |> ReviewQueries.top(limit)
      |> join(:left, [r], rating_rank in subquery(ReviewQueries.rating_rank()), on: rating_rank.anime_id == r.anime_id)
      |> preload(:anime)
      |> order_by([r], [desc: r.rating, desc: r.count, desc: r.anime_id])
      |> select([summary, rating_rank, pop_rank], %{summary: summary, rating_rank: rating_rank})

    Repo.all(top_rated)
  end

  def top_for_user(%User{} = user) do
    Ecto.assoc(user, :reviews)
    |> ReviewQueries.top(10)
    |> preload(:anime)
    |> Repo.all()
  end

  def recent_for_user(%User{} = user) do
    Ecto.assoc(user, :reviews)
    |> ReviewQueries.latest(10)
    |> preload([:anime, :author])
    |> Repo.all()
  end

  def get_rating_summary(rated_id) do
    Chuuni.Reviews.ReviewQueries.review_summary()
    |> where(anime_id: ^rated_id)
    |> Repo.one()
  end

  def get_rating_rank(rated_id) do
    if rank = Repo.one(ReviewQueries.rating_rank(rated_id)) do
      rank.rank
    end
  end

  def get_popularity_rank(rated_id) do
    if rank = Repo.one(ReviewQueries.popularity_rank(rated_id)) do
      rank.rank
    end
  end

  def reviews_for_shelf(%Shelf{} = shelf) do
    Repo.all(
      from r in Review,
        join: a in assoc(r, :anime),
        join: s in assoc(a, :shelves),
        where: s.id == ^shelf.id,
        select: {r.anime_id, r}
    )
    |> Map.new()
  end

  @doc """
  Returns the list of reviews.

  ## Examples

      iex> list_reviews()
      [%Review{}, ...]

  """
  def list_reviews do
    Repo.all(Review)
  end

  def latest_reviews do
    ReviewQueries.latest(10)
    |> preload(:author)
    |> Repo.all()
  end

  def latest_reviews_for_item(itemid) do
    ReviewQueries.latest(10)
    |> where(anime_id: ^itemid)
    |> preload(:author)
    |> Repo.all()
  end

  @doc """
  Gets a single review.

  Raises `Ecto.NoResultsError` if the Review does not exist.

  ## Examples

      iex> get_review!(123)
      %Review{}

      iex> get_review!(456)
      ** (Ecto.NoResultsError)

  """
  def get_review!(id) do
    Repo.get!(Review, id)
    |> Repo.preload([:author, :anime])
  end

  def get_review_by_user(anime_id, author_id) do
    Repo.get_by(Review, anime_id: anime_id, author_id: author_id)
    |> Repo.preload([:author, :anime])
  end

  @doc """
  Creates a review.

  ## Examples

      iex> create_review(%{field: value})
      {:ok, %Review{}}

      iex> create_review(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_review(attrs \\ %{}) do
    %Review{}
    |> Review.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a review.

  ## Examples

      iex> update_review(review, %{field: new_value})
      {:ok, %Review{}}

      iex> update_review(review, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_review(%Review{} = review, attrs) do
    review
    |> Review.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a review.

  ## Examples

      iex> delete_review(review)
      {:ok, %Review{}}

      iex> delete_review(review)
      {:error, %Ecto.Changeset{}}

  """
  def delete_review(%Review{} = review) do
    Repo.delete(review)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking review changes.

  ## Examples

      iex> change_review(review)
      %Ecto.Changeset{data: %Review{}}

  """
  def change_review(%Review{} = review, attrs \\ %{}) do
    Review.changeset(review, attrs)
  end
end
