defmodule Chuuni.Reviews.ReviewQueries do
  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime
  alias Chuuni.Reviews.Review
  alias Chuuni.Reviews.ReviewSummary

  import Ecto.Query

  def review_summary do
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

  def bayesian_review_summary(query \\ Review) do
    overall_rating_average =
      from r in subquery(query), select: avg(r.rating)

    lower_quartile_review_count =
      from r in Review,
        join: rs in subquery(review_summary()), on: r.anime_id == rs.anime_id,
        select: fragment("percentile_cont(0.25) within group (order by ? asc)", rs.count)

    from rs in subquery(review_summary()),
      select: %ReviewSummary{
        anime_id: rs.anime_id,
        count: rs.count,
        rating: (rs.rating * rs.count + subquery(overall_rating_average) * subquery(lower_quartile_review_count)) / (rs.count + subquery(lower_quartile_review_count))
      }
  end

  def top(query, count) do
    from r in subquery(query),
      order_by: [desc: :rating],
      limit: ^count
  end

  def trending(count) do
    recent =
      from r in Review,
        where: r.inserted_at >= ago(1, "week")

    from rs in subquery(bayesian_review_summary(recent)),
      order_by: [desc: rs.rating, desc: rs.count],
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
    from r in subquery(bayesian_review_summary()),
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

  def average_rating(%User{} = user) do
    from r in Ecto.assoc(user, :ratings),
      select: avg(r.rating)
  end

  def similarity(%User{id: ua_id}, %User{id: ub_id}) do
    average_ratings =
      from r in Review,
      group_by: :author_id,
      select: %{user_id: r.author_id, average_rating: avg(r.rating)}

    normalized_ratings =
      from r in Review,
        join: avg_rating in subquery(average_ratings), on: r.author_id == avg_rating.user_id,
        select: %{
          id: r.id,
          author_id: r.author_id,
          anime_id: r.anime_id,
          normalized_rating: r.rating - avg_rating.average_rating
        }

    paired_ratings =
      from a in Anime,
      join: ra in ^(from subquery(normalized_ratings), where: [author_id: ^ua_id]), on: ra.anime_id == a.id,
      join: rb in ^(from subquery(normalized_ratings), where: [author_id: ^ub_id]), on: rb.anime_id == a.id,
      select: %{rating_a: coalesce(ra.normalized_rating, 0.0), rating_b: coalesce(rb.normalized_rating, 0.0)}

    terms =
      from r in subquery(paired_ratings),
        select: %{
          term_a: sum(r.rating_a * r.rating_b),
          term_b: fragment("sqrt(?)", sum(r.rating_a * r.rating_a)),
          term_c: fragment("sqrt(?)", sum(r.rating_b * r.rating_b))
        }

    from t in subquery(terms),
      select: t.term_a / fragment("NULLIF(?, 0)", (t.term_b * t.term_c))
  end
end
