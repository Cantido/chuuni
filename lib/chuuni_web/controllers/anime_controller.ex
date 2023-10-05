defmodule ChuuniWeb.AnimeController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews
  alias Chuuni.Media
  alias Chuuni.Media.Anime

  require Logger

  def search(conn, %{"query" => query}) do
    local_results = Media.search_anime(query)

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
              large
            }
            studios(sort: NAME) {
              nodes {
                name
              }
            }
            startDate {
              year
            }
            endDate {
              year
            }
          }
        }
      }
    """,
    %{search: query, perPage: 10, page: 1}
    )

    conn
    |> put_layout(html: false)
    |> render(:search_results, local_results: local_results, anilist_results: resp.body["data"]["Page"]["media"])
  end

  def show(conn, %{"id" => id}) do
    anime = Media.get_anime!(id)
    rating_summary = Reviews.get_rating_summary(id)
    rating_rank = Reviews.get_rating_rank(id)
    popularity_rank = Reviews.get_popularity_rank(id)

    reviews = Reviews.latest_reviews_for_item(id)


    user_review =
      if current_user = conn.assigns[:current_user] do
        Reviews.get_review_by_user(id, current_user.id)
      end

    review_changeset = Reviews.change_review(%Chuuni.Reviews.Review{}, %{anime_id: id})

    render(conn, :show,
      anime: anime,
      rating_summary: rating_summary,
      reviews: reviews,
      rating_rank: rating_rank,
      popularity_rank: popularity_rank,
      user_review: user_review,
      review_changeset: review_changeset)
  end

  def import(conn, %{"provider" => "anilist", "id" => id}) do
    case Media.import_anilist_anime(id) do
      {:ok, anime} ->
        conn
        |> put_flash(:info, "Anime imported successfully.")
        |> redirect(to: ~p"/anime/#{anime}")

      {:error, error} ->
        Logger.error("Failed to import anime: #{inspect error}")
        conn
        |> put_flash(:error, "Failed to import anime. An admin has been notified")
        |> redirect(to: ~p"/")
    end
  end

  def edit(conn, %{"anime_id" => id}) do
    anime = Media.get_anime!(id)
    changeset = Media.change_anime(anime)
    render(conn, :edit, anime: anime, changeset: changeset)
  end

  def update(conn, %{"anime_id" => id, "anime" => anime_params}) do
    anime = Media.get_anime!(id)

    with {:ok, anime} <- Media.update_anime(anime, anime_params),
         :ok <- update_cover(anime, anime_params["cover"]) do
      conn
      |> put_flash(:info, "Anime updated successfully.")
      |> redirect(to: ~p"/anime/#{anime}")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, anime: anime, changeset: changeset)
    end
  end

  defp update_cover(_, nil) do
    :ok
  end

  defp update_cover(%Anime{} = anime, %Plug.Upload{path: path}) do
    Media.replace_anime_cover(anime, path)
  end
end
