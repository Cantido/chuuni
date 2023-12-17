defmodule ChuuniWeb.ShelfController do
  use ChuuniWeb, :controller

  alias Chuuni.Accounts
  alias Chuuni.Shelves
  alias Chuuni.Shelves.Shelf
  alias Chuuni.Reviews

  import ChuuniWeb.UserAuth, only: [require_authenticated_user: 2]

  plug :require_authenticated_user

  def index(conn, %{"username" => name}) do
    user = Accounts.get_user_by_name(name)
    shelves = Shelves.list_shelves_for_user(user)
    shelf = %Shelf{
      id: :all,
      items: Enum.flat_map(shelves, &(&1.items))
    }
    render(conn, :show, user: user, shelf: shelf, shelves: shelves)
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
    render(conn, :show, user: shelf.author, shelf: shelf, shelves: shelves)
  end

  def edit(conn, %{"id" => id}) do
    shelf = Shelves.get_shelf!(id)
    changeset = Shelves.change_shelf(shelf)
    render(conn, :edit, shelf: shelf, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shelf" => shelf_params}) do
    shelf = Shelves.get_shelf!(id)

    case Shelves.update_shelf(shelf, shelf_params) do
      {:ok, shelf} ->
        conn
        |> redirect(to: ~p"/shelves/#{shelf}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shelf: shelf, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shelf = Shelves.get_shelf!(id)
    {:ok, _shelf} = Shelves.delete_shelf(shelf)

    conn
    |> put_flash(:info, "Shelf deleted successfully.")
    |> redirect(to: ~p"/shelves")
  end
end
