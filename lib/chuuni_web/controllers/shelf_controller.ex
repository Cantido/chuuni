defmodule ChuuniWeb.ShelfController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  alias Chuuni.Shelves
  alias Chuuni.Shelves.Shelf
  alias Chuuni.Reviews.Review

  import Ecto.Query
  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]

  plug :require_authenticated_user

  def index(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)
    shelves = Shelves.list_shelves_for_user(user)
    anime_with_reviews =
      Enum.flat_map(shelves, &(&1.items))
      |> pair_reviews(user.id)

    render(conn, :show, user: user, active_shelf_id: :all, shelves: shelves, anime: anime_with_reviews)
  end

  def new(conn, _params) do
    changeset = Shelves.change_shelf(%Shelf{author_id: conn.assigns[:current_user].id})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"shelf" => shelf_params}) do
    case Shelves.create_shelf(shelf_params) do
      {:ok, _shelf} ->
        resp(conn, 200, "")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shelf = Shelves.get_shelf!(id)
    shelves = Shelves.list_shelves_for_user(shelf.author)
    anime_with_reviews = pair_reviews(shelf.items, shelf.author_id)

    render(conn, :show, user: shelf.author, active_shelf_id: shelf.id, shelves: shelves, anime: anime_with_reviews)
  end

  def edit(conn, %{"id" => id}) do
    shelf = Shelves.get_shelf!(id)
    changeset = Shelves.change_shelf(shelf)
    render(conn, :edit, shelf: shelf, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shelf" => shelf_params}) do
    shelf = Shelves.get_shelf!(id)
    user = Chuuni.Repo.one(Ecto.assoc(shelf, :author))

    case Shelves.update_shelf(shelf, shelf_params) do
      {:ok, shelf} ->
        conn
        |> redirect(to: ~p"/@#{user}/shelves/#{shelf}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shelf: shelf, changeset: changeset)
    end
  end

  defp pair_reviews(items, author_id) do
    reviews = reviews(Enum.map(items, &(&1.anime_id)), author_id)

    Enum.map(items, fn item ->
      %{
        anime: item.anime,
        review: Map.get(reviews, item.anime_id)
      }
    end)
    |> Enum.sort_by(fn item ->
      Map.get(item, :review, %{})
      |> then(&(&1 || %{}))
      |> Map.get(:rating, 0)
    end, :desc)
  end

  defp reviews(anime_ids, author_id) do
    Chuuni.Repo.all(
      from r in Review,
        where: r.anime_id in ^anime_ids,
        where: r.author_id == ^author_id,
        select: {r.anime_id, r}
    )
    |> Map.new()
  end
end
