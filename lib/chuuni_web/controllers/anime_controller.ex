defmodule ChuuniWeb.AnimeController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews

  def search(conn, %{"query" => query}) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($search: String, $perPage: Int, $page: Int) {
        Page(page: $page, perPage: $perPage) {
          pageInfo {
            total
            perPage
          }
          media(search: $search, type: ANIME, sort: FAVOURITES_DESC) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              medium
            }
          }
        }
      }
    """,
    %{search: query, perPage: 10, page: 1}
    )

    conn
    |> put_layout(html: :bare)
    |> put_root_layout(html: :bare)
    |> render(:search_results, results: resp.body["data"]["Page"]["media"])
  end

  def summary_card(conn, %{"anime_id" => id}) do
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

    conn
    |> put_layout(html: :bare)
    |> put_root_layout(html: :bare)
    |> render(:summary_card, anime: resp.body["data"]["Media"])
  end

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

    rating_summary = Reviews.get_rating_summary(id)
    rating_rank = Reviews.get_rating_rank(id)
    popularity_rank = Reviews.get_popularity_rank(id)

    reviews = Reviews.latest_reviews_for_item(id)

    user_review =
      if current_user = conn.assigns[:current_user] do
        Reviews.get_review_by_user(id, current_user.id)
      end

    review_changeset = Reviews.change_review(%Chuuni.Reviews.Review{}, %{item_reviewed: id})

    render(conn, :show,
      anime: resp.body["data"]["Media"],
      rating_summary: rating_summary,
      reviews: reviews,
      rating_rank: rating_rank,
      popularity_rank: popularity_rank,
      user_review: user_review,
      review_changeset: review_changeset)
  end
end
