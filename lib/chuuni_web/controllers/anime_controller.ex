defmodule ChuuniWeb.AnimeController do
  use ChuuniWeb, :controller

  alias Chuuni.Media
  alias Chuuni.Media.Anime

  def show(conn, %{"id" => id}) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($id: Int) {
        Media (id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
          }
          description(asHtml: true)
          episodes
        }
      }
    """,
    %{id: id}
    )

    rating_summary = Chuuni.Reviews.get_rating_summary(id)
    rating_rank = Chuuni.Reviews.get_rating_rank(id)
    popularity_rank = Chuuni.Reviews.get_popularity_rank(id)

    reviews = Chuuni.Reviews.latest_reviews_for_item(id)

    user_review =
      if current_user = conn.assigns[:current_user] do
        Chuuni.Reviews.get_review_by_user(id, current_user.id)
      end

    render(conn, :show,
      anime: resp.body["data"]["Media"],
      rating_summary: rating_summary,
      reviews: reviews,
      rating_rank: rating_rank,
      popularity_rank: popularity_rank,
      user_review: user_review)
  end
end
