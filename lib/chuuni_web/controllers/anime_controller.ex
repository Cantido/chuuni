defmodule ChuuniWeb.AnimeController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews
  alias Chuuni.Shelves
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Media
  alias Chuuni.Media.Anime

  require Logger

  def new_search(conn, _params) do
    render(conn, :search_controls)
  end

  def show(conn, %{"id" => id}) do
    anime = Media.get_anime!(id)
    rating_summary = Reviews.get_rating_summary(id)
    rating_rank = Reviews.get_rating_rank(id)
    popularity_rank = Reviews.get_popularity_rank(id)

    reviews = Reviews.latest_reviews_for_item(id)

    anime_count = Media.count_anime()

    user_review =
      if current_user = conn.assigns[:current_user] do
        Reviews.get_review_by_user(id, current_user.id)
      end

    user_shelf_item =
      if current_user = conn.assigns[:current_user] do
        Shelves.get_user_shelf_for_anime(current_user, anime)
      end

    review_changeset = Reviews.change_review(%Chuuni.Reviews.Review{}, %{anime_id: id})

    render(conn, :show,
      anime: anime,
      anime_count: anime_count,
      rating_summary: rating_summary,
      reviews: reviews,
      rating_rank: rating_rank,
      popularity_rank: popularity_rank,
      user_review: user_review,
      user_shelf_item: user_shelf_item,
      review_changeset: review_changeset)
  end

  def rating_breakdown(conn, %{"anime_id" => id}) do
    ratings = Reviews.get_rating_breakdown(id)
    rating_count = Enum.sum(Map.values(ratings))

    conn
    |> render(:rating_breakdown, ratings: ratings, rating_count: rating_count)
  end

  def shelf(conn, %{"anime_id" => id}) do
    anime = Media.get_anime!(id)

    if current_user = conn.assigns[:current_user] do
      user_shelves =
        Shelves.list_shelves_for_user(current_user)

      changeset = Shelves.change_shelf_item(%ShelfItem{})

      current_shelf =
        Enum.find(user_shelves, fn shelf -> Enum.any?(shelf.items, &(&1.anime_id == anime.id)) end)

      conn
      |> render(:shelf_select, shelves: user_shelves, anime: anime, current_shelf: current_shelf, changeset: changeset)
    else
      conn
      |> resp(:no_content, "")
    end
  end

  def select_shelf(conn, %{"anime_id" => id, "shelf_item" => shelf_item_params}) do
    anime = Media.get_anime!(id)
    if user = conn.assigns[:current_user] do
      shelf_item_params =
        shelf_item_params
        |> Map.put("anime_id", id)
        |> Map.put("author_id", user.id)
      case Shelves.move_shelf_item(anime, user, shelf_item_params) do
        {:ok, _shelf_item} ->
          user_shelves =
            Shelves.list_shelves_for_user(user)

          current_shelf =
            Enum.find(user_shelves, fn shelf -> Enum.any?(shelf.items, &(&1.anime_id == anime.id)) end)

          changeset = Shelves.change_shelf_item(%ShelfItem{}, %{anime_id: id, author_id: user.id})

          conn
          |> render(:shelf_select, shelves: user_shelves, anime: anime, current_shelf: current_shelf, success_message: "Moved!", changeset: changeset)
        {:error, changeset} ->
          Logger.error("error adding shelf item: #{inspect changeset}")
          user_shelves =
            Shelves.list_shelves_for_user(user)

          current_shelf =
            Enum.find(user_shelves, fn shelf -> Enum.any?(shelf.items, &(&1.anime_id == anime.id)) end)

          conn
          |> render(:shelf_select, shelves: user_shelves, anime: anime, current_shelf: current_shelf, changeset: changeset)
      end
    else
      conn
      |> put_view(html: ChuuniWeb.UserAuthHTML)
      |> render(:must_be_logged_in)
    end
  end


  def import(conn, %{"provider" => "anilist", "id" => id}) do
    if conn.assigns[:current_user] do
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
    else
      conn
      |> put_view(html: ChuuniWeb.UserAuthHTML)
      |> render(:must_be_logged_in)
    end
  end

  def edit(conn, %{"id" => id}) do
    if conn.assigns[:current_user] do
      anime = Media.get_anime!(id)
      changeset = Media.change_anime(anime)
      render(conn, :edit, anime: anime, changeset: changeset)
    else
      conn
      |> put_view(html: ChuuniWeb.UserAuthHTML)
      |> render(:must_be_logged_in)
    end
  end

  def update(conn, %{"id" => id, "anime" => anime_params}) do
    if conn.assigns[:current_user] do
      anime = Media.get_anime!(id)

      with {:ok, anime} <- Media.update_anime(anime, anime_params),
           :ok <- update_cover(anime, anime_params["cover"]) do
        conn
        |> put_flash(:info, "Anime updated successfully.")
        |> redirect(to: ~p"/anime/#{anime}")
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit, anime: anime, changeset: changeset)
        {:error, _err} ->
          conn
          |> put_view(ChuuniWeb.ErrorHTML)
          |> render(:"500")
      end
    else
      conn
      |> put_view(html: ChuuniWeb.UserAuthHTML)
      |> render(:must_be_logged_in)
    end
  end

  defp update_cover(_, nil) do
    :ok
  end

  defp update_cover(%Anime{} = anime, %Plug.Upload{path: path}) do
    Media.replace_anime_cover(anime, path)
  end
end
