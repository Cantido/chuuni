defmodule Chuuni.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Repo

  alias Chuuni.Reviews.Rating

  @doc """
  Returns the list of ratings.

  ## Examples

      iex> list_ratings()
      [%Rating{}, ...]

  """
  def list_ratings do
    Repo.all(Rating)
  end

  def top_rated do
    top_rated_query =
      from r in Rating,
      group_by: :item_rated,
      select: %{item_rated: r.item_rated, value: avg(r.value), count: count()},
      order_by: [desc: avg(r.value)],
      limit: 10

    Repo.all(top_rated_query)
  end

  @doc """
  Gets a single rating.

  Raises `Ecto.NoResultsError` if the Rating does not exist.

  ## Examples

      iex> get_rating!(123)
      %Rating{}

      iex> get_rating!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rating!(id) do
    Repo.get!(Rating, id)
    |> Repo.preload(:author)
  end

  def get_rating_summary(rated_id) do
    Repo.one(
      from r in Rating,
      where: [item_rated: ^rated_id],
      select: %{item_rated: ^rated_id, count: count(), avg: avg(r.value)}
    )
  end

  def get_rating_rank(rated_id) do
    summary = get_rating_summary(rated_id)

    higher_ranks =
      from r in Rating,
      group_by: :item_rated,
      having: avg(r.value) >= ^summary.avg,
      select: [:item_rated]

    Enum.count(Repo.all(higher_ranks)) + 1
  end

  def get_popularity_rank(rated_id) do
    summary = get_rating_summary(rated_id)

    higher_ranks =
      from r in Rating,
      group_by: :item_rated,
      having: count(r.author_id, :distinct) >= ^summary.count,
      select: [:item_rated]

    Enum.count(Repo.all(higher_ranks)) + 1
  end

  @doc """
  Creates a rating.

  ## Examples

      iex> create_rating(%{field: value})
      {:ok, %Rating{}}

      iex> create_rating(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rating(attrs \\ %{}) do
    %Rating{
      value_best: Decimal.new("10"),
      value_worst: Decimal.new("1")
    }
    |> Rating.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rating.

  ## Examples

      iex> update_rating(rating, %{field: new_value})
      {:ok, %Rating{}}

      iex> update_rating(rating, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rating(%Rating{} = rating, attrs) do
    rating
    |> Rating.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rating.

  ## Examples

      iex> delete_rating(rating)
      {:ok, %Rating{}}

      iex> delete_rating(rating)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rating(%Rating{} = rating) do
    Repo.delete(rating)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rating changes.

  ## Examples

      iex> change_rating(rating)
      %Ecto.Changeset{data: %Rating{}}

  """
  def change_rating(%Rating{} = rating, attrs \\ %{}) do
    Rating.changeset(rating, attrs)
  end

  alias Chuuni.Reviews.Review

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
    Repo.all(
      from r in Review,
      order_by: [desc: :inserted_at],
      limit: 10,
      preload: :author
    )
  end

  def latest_reviews_for_item(itemid) do
    Repo.all(
      from r in Review,
      where: [item_reviewed: ^itemid],
      order_by: [desc: :inserted_at],
      limit: 10,
      preload: :author
    )
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
    |> Repo.preload(:author)
  end

  def get_review_by_user(item_reviewed, author_id) do
    Repo.get_by(Review, item_reviewed: item_reviewed, author_id: author_id)
    |> Repo.preload(:author)
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
