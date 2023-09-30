defmodule ChuuniWeb.RatingController do
  use ChuuniWeb, :controller

  alias Chuuni.Reviews
  alias Chuuni.Reviews.Rating

  def index(conn, _params) do
    ratings = Reviews.top_rated()
    render(conn, :index, ratings: ratings)
  end

  def new(conn, _params) do
    changeset = Reviews.change_rating(%Rating{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"rating" => rating_params}) do
    rating_params = Map.put(rating_params, "author_id", conn.assigns[:current_user].id)
    case Reviews.create_rating(rating_params) do
      {:ok, rating} ->
        conn
        |> put_flash(:info, "Rating created successfully.")
        |> redirect(to: ~p"/ratings/#{rating}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    rating = Reviews.get_rating!(id)
    render(conn, :show, rating: rating)
  end

  def edit(conn, %{"id" => id}) do
    rating = Reviews.get_rating!(id)
    changeset = Reviews.change_rating(rating)
    render(conn, :edit, rating: rating, changeset: changeset)
  end

  def update(conn, %{"id" => id, "rating" => rating_params}) do
    rating = Reviews.get_rating!(id)

    case Reviews.update_rating(rating, rating_params) do
      {:ok, rating} ->
        conn
        |> put_flash(:info, "Rating updated successfully.")
        |> redirect(to: ~p"/ratings/#{rating}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, rating: rating, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    rating = Reviews.get_rating!(id)
    {:ok, _rating} = Reviews.delete_rating(rating)

    conn
    |> put_flash(:info, "Rating deleted successfully.")
    |> redirect(to: ~p"/ratings")
  end
end
