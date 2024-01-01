defmodule ChuuniWeb.AboutController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews

  import Ecto.Query

  def index(conn, _params) do
    render(conn, :index)
  end

  def averages(conn, _params) do
    [top] = Reviews.top_rated(1)

    top_mean_rating =
      Chuuni.Reviews.ReviewQueries.review_summary()
      |> where(anime_id: ^top.summary.anime.id)
      |> Chuuni.Repo.one()

    global_rating_average = Chuuni.Repo.aggregate(Chuuni.Reviews.Review, :avg, :rating)
    global_rating_count = Chuuni.Repo.aggregate(Chuuni.Reviews.Review, :count)
    rating_lower_quartile =
      Chuuni.Repo.one(
        from r in Chuuni.Reviews.Review,
          join: rs in subquery(Chuuni.Reviews.ReviewQueries.review_summary()), on: r.anime_id == rs.anime_id,
          select: fragment("percentile_cont(0.25) within group (order by ? asc)", rs.count)
      )

    render(conn, :averages,
      top_anime: top,
      top_mean_rating: top_mean_rating,
      global_rating_average: global_rating_average,
      global_rating_count: global_rating_count,
      rating_lower_quartile: rating_lower_quartile
    )
  end
end
