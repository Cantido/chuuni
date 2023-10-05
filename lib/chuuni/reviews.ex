defmodule Chuuni.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Repo

  alias Chuuni.Reviews.Review
  alias Chuuni.Media.Anime

  def top_rated do
    top_rated_query =
      from r in Review,
      group_by: :anime_id,
      select: %{anime_id: r.anime_id, rating: avg(r.rating), count: count()},
      order_by: [desc: avg(r.rating), desc: count(), asc: r.anime_id],
      limit: 10

    top_rated_with_metadata =
      from a in Anime,
      join: r in subquery(top_rated_query),
      on: [anime_id: a.id],
      select: %{anime: a, rating: r.rating, count: r.count},
      order_by: [desc: r.rating, desc: r.count, desc: a.id]

    Repo.all(top_rated_with_metadata)
    |> with_rank()
    |> Enum.map(fn {item, rank} ->
      Map.put(item, :rank, rank)
    end)
  end

  defp with_rank(enumerable) do
    {_, _, _, ranks} =
    Enum.reduce(enumerable, {1, 0, nil, []}, fn elem, {current_rank, ranked_count, last_rating, ranks} ->
      current_rating = elem.rating

      if is_nil(last_rating) or current_rating == last_rating do
        # we have a tie, they will share the same ranking
        {current_rank, ranked_count + 1, current_rating, [current_rank | ranks]}
      else
        next_rank = ranked_count + 1
        {next_rank, ranked_count + 1, current_rating, [next_rank | ranks]}
      end
    end)

    Enum.zip(enumerable, Enum.reverse(ranks))
  end

  require Logger

  def get_rating_summary(rated_id) do
    summary = Repo.one(
      from r in Review,
      where: [anime_id: ^rated_id],
      where: not is_nil(r.rating),
      select: %{anime_id: ^rated_id, count: count(r.author_id, :distinct), avg: avg(r.rating)}
    )

    if is_nil(summary.avg) && summary.count != 0 do
      raise "This shouldn't happen"
    end

    summary
  end

  def get_rating_rank(rated_id) do
    summary = get_rating_summary(rated_id)

    if summary.count == 0 do
      nil
    else
      higher_ranks =
        from r in Review,
        group_by: :anime_id,
        having: avg(r.rating) >= ^summary.avg,
        select: [:anime_id]

      Enum.count(Repo.all(higher_ranks)) + 1
    end
  end

  def get_popularity_rank(rated_id) do
    summary = get_rating_summary(rated_id)

    if summary.count == 0 do
      nil
    else
      higher_ranks =
        from r in Review,
        group_by: :anime_id,
        having: count(r.author_id, :distinct) >= ^summary.count,
        select: [:anime_id]

      Enum.count(Repo.all(higher_ranks)) + 1
    end
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
      where: [anime_id: ^itemid],
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
