defmodule Chuuni.Reviews.ReviewQueries do
  alias Chuuni.Reviews.Review
  alias Chuuni.Reviews.ReviewSummary

  import Ecto.Query

  def review_summary() do
    from r in Review,
      group_by: r.anime_id,
      where: not is_nil(r.rating),
      select: %ReviewSummary{anime_id: r.anime_id, count: count(r.author_id, :distinct), rating: avg(r.rating)}
  end

  def review_summary(query) do
    from r in subquery(query),
      group_by: r.anime_id,
      where: not is_nil(r.rating),
      select: %ReviewSummary{anime_id: r.anime_id, count: count(r.author_id, :distinct), rating: avg(r.rating)}
  end

  def top(query, count) do
    from r in subquery(query),
      order_by: [desc: :rating],
      limit: ^count
  end

  def latest(count) do
    from r in Review,
      order_by: [desc: :inserted_at],
      limit: ^count
  end

  def latest(query, count) do
    from r in subquery(query),
      order_by: [desc: :inserted_at],
      limit: ^count
  end

  def rating_rank do
    from r in subquery(review_summary()),
      select: %{anime_id: r.anime_id, rank: over(rank(), :anime)},
      windows: [anime: [order_by: [desc_nulls_last: r.rating]]]
  end

  def rating_rank(anime_id) do
    from r in subquery(rating_rank()),
      where: [anime_id: ^anime_id]
  end

  def popularity_rank do
    from r in subquery(review_summary()),
      select: %{anime_id: r.anime_id, rank: over(rank(), :anime)},
      windows: [anime: [order_by: [desc_nulls_last: r.count]]]
  end

  def popularity_rank(anime_id) do
    from r in subquery(popularity_rank()),
      where: [anime_id: ^anime_id]
  end

end
