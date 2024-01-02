defmodule ChuuniWeb.RecommendationController do
  use ChuuniWeb, :controller

  alias Chuuni.Media
  alias Chuuni.Reviews
  alias Chuuni.Reviews.Recommendation
  alias Chuuni.Repo

  import Ecto.Query
  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]

  plug :require_authenticated_user

  def show(conn, %{"anime_id" => anime_id, "recommended_anime_id" => rec_anime_id}) do
    anime = Media.get_anime!(anime_id)
    rec_anime = Media.get_anime!(rec_anime_id)

    upvote_count = 420
    downvote_count = 69

    rating_summary = Reviews.get_rating_summary(anime.id)
    rec_rating_summary = Reviews.get_rating_summary(rec_anime_id)

    current_vote =
      Repo.one(
        from r in Recommendation,
        where: [
          user_id: ^conn.assigns.current_user.id,
          anime_id: ^anime_id,
          recommended_id: ^rec_anime_id
        ],
        select: r.vote
      )

    render(conn, :show,
      anime: anime,
      recommended_anime: rec_anime,
      recommended_rating_summary: rec_rating_summary,
      upvote_count: upvote_count,
      downvote_count: downvote_count,
      rating_summary: rating_summary,
      current_vote: current_vote
    )
  end

  def new(conn, %{"anime_id" => anime_id} = params) do
    anime = Media.get_anime!(anime_id)
    rating_summary = Reviews.get_rating_summary(anime.id)

    query = Map.get(params, "q")

    local_results =
      if query do
        Media.search_anime(query)
      else
        []
      end

    local_anilist_ids =
      Enum.map(local_results, fn result ->
        result.external_ids.anilist
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&String.to_integer/1)

    anilist_results =
      if query do
        Media.search_anilist(query, id_not_in: local_anilist_ids)
      else
        []
      end

    render(conn, :new, anime: anime, rating_summary: rating_summary, query: query, local_results: local_results, anilist_results: anilist_results)
  end

  def search(conn, %{"anime_id" => anime_id, "q" => query}) do
    anime = Media.get_anime!(anime_id)
    local_results = Media.search_anime(query)
    anilist_results = Media.search_anilist(query)


    render(conn, :search_results, anime: anime, local_results: local_results, anilist_results: anilist_results)
  end

  def create(conn, %{"anime_id" => anime_id, "recommended_anime_id" => rec_anime_id, "vote" => vote}) do
    anime = Media.get_anime!(anime_id)
    rec_anime = Media.get_anime!(rec_anime_id)

    rec = save_vote(anime_id, rec_anime_id, conn.assigns.current_user.id, :up)

    rec_rating_summary = Reviews.get_rating_summary(rec_anime_id)

    conn
    |> render(:rec_anime_column, anime: anime, recommended_anime: rec_anime, recommended_rating_summary: rec_rating_summary)
  end

  def import(conn, %{"anime_id" => anime_id, "recommended_anilist_id" => rec_anilist_id, "vote" => vote}) do
    anime = Media.get_anime!(anime_id)
    {:ok, rec_anime} = Chuuni.Media.Anilist.import_anilist_anime(String.to_integer(rec_anilist_id))

    rec = save_vote(anime_id, rec_anime.id, conn.assigns.current_user.id, :up)

    rec_rating_summary = Reviews.get_rating_summary(rec_anime.id)

    conn
    |> put_req_header("hx-location", ~p"/anime/#{anime}/recommendations/#{rec_anime}")
    |> render(:rec_anime_column, anime: anime, recommended_anime: rec_anime, recommended_rating_summary: rec_rating_summary)
  end

  def like(conn, %{"anime_id" => anime_id, "recommended_anime_id" => rec_anime_id} = params) do
    {:ok, rec} = save_vote(anime_id, rec_anime_id, conn.assigns.current_user.id, :up)

    render_voting(conn, rec, params["style"])
  end

  def dislike(conn, %{"anime_id" => anime_id, "recommended_anime_id" => rec_anime_id} = params) do
    {:ok, rec} = save_vote(anime_id, rec_anime_id, conn.assigns.current_user.id, :down)

    render_voting(conn, rec, params["style"])
  end

  def votes(conn, %{"anime_id" => anime_id, "recommended_anime_id" => rec_anime_id} = params) do
    rec = Repo.one!(from r in Recommendation, where: [anime_id: ^anime_id, recommended_id: ^rec_anime_id, user_id: ^conn.assigns.current_user.id])

    render_voting(conn, rec, params["style"])
  end

  defp render_voting(conn, rec, style) do
    anime = Media.get_anime!(rec.anime_id)
    rec_anime = Media.get_anime!(rec.recommended_id)

    upvote_count =
      Repo.aggregate(
        from(r in Recommendation, where: [anime_id: ^rec.anime_id, recommended_id: ^rec.recommended_id, vote: :up]),
        :count
      )

    downvote_count =
      Repo.aggregate(
        from(r in Recommendation, where: [anime_id: ^rec.anime_id, recommended_id: ^rec.recommended_id, vote: :down]),
        :count
      )

    template =
      if style == "card" do
        :vote_card
      else
        :vote_buttons
      end

    render(conn, template,
      anime: anime,
      recommended: rec_anime,
      current_vote: rec.vote,
      upvote_count: upvote_count,
      downvote_count: downvote_count
    )
  end

  defp save_vote(anime_id, rec_anime_id, user_id, vote) do
    params = %{
      anime_id: anime_id,
      recommended_id: rec_anime_id,
      user_id: user_id,
      vote: vote
    }

    %Recommendation{}
    |> Recommendation.changeset(params)
    |> Repo.insert(conflict_target: [:user_id, :anime_id, :recommended_id], on_conflict: [set: [vote: vote]])
  end
end
