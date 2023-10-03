defmodule Chuuni.Reviews do
  @moduledoc """
  The Reviews context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Repo

  alias Chuuni.Reviews.Review

  def top_rated do
    top_rated_query =
      from r in Review,
      group_by: :item_reviewed,
      select: %{item_reviewed: r.item_reviewed, rating: avg(r.rating), count: count()},
      order_by: [desc: avg(r.rating), desc: count(), asc: r.item_reviewed],
      limit: 10

    Repo.all(top_rated_query)
    |> with_rank()
    |> Enum.map(fn {item, rank} ->
      Neuron.Config.set(url: "https://graphql.anilist.co")

      Neuron.query("""
        query ($id: Int) {
          Media (id: $id, type: ANIME) {
            title {
              english
              romaji
            }
            coverImage {
              large
            }
            startDate {
              year
            }
            endDate {
              year
            }
            studios(sort: NAME) {
              nodes {
                name
              }
            }
          }
        }
        """,
        %{id: item.item_reviewed}
      )
      |> case do
        {:ok, resp} ->
          data = resp.body["data"]["Media"]

          item
          |> Map.put(:has_data, true)
          |> Map.put(:anime, data)
          |> Map.put(:title, data["title"]["english"])
          |> Map.put(:poster, data["coverImage"]["large"])
        _ ->
          item
          |> Map.put(:has_data, false)
          |> Map.put(:title, nil)
          |> Map.put(:poster, nil)
      end
      |> Map.put(:rank, rank)
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
      where: [item_reviewed: ^rated_id],
      where: not is_nil(r.rating),
      select: %{item_reviewed: ^rated_id, count: count(r.author_id, :distinct), avg: avg(r.rating)}
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
        group_by: :item_reviewed,
        having: avg(r.rating) >= ^summary.avg,
        select: [:item_reviewed]

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
        group_by: :item_reviewed,
        having: count(r.author_id, :distinct) >= ^summary.count,
        select: [:item_reviewed]

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
