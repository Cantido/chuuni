defmodule Chuuni.Reviews.ReviewQueries do
  alias Chuuni.Reviews.Review

  import Ecto.Query

  def review_summary() do
    from r in Review,
      group_by: r.anime_id,
      where: not is_nil(r.rating),
      select: %{anime_id: r.anime_id, count: count(r.author_id, :distinct), avg: avg(r.rating)}
  end

  def review_summary(query) do
    from r in query,
      group_by: r.anime_id,
      where: not is_nil(r.rating),
      select: %{anime_id: r.anime_id, count: count(r.author_id, :distinct), avg: avg(r.rating)}
  end

  def top(query, count) do
    from r in query,
      order_by: [desc: r.rating],
      limit: ^count
  end
end
