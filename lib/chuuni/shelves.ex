defmodule Chuuni.Shelves do
  @moduledoc """
  The Shelves context.
  """

  import Ecto.Query, warn: false
  alias Chuuni.Repo

  alias Chuuni.Shelves.Shelf
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Shelves.ShelfQueries
  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime

  @doc """
  Returns the list of shelves.

  ## Examples

      iex> list_shelves()
      [%Shelf{}, ...]

  """
  def list_shelves do
    Repo.all(Shelf)
  end

  def list_shelves_for_user(%User{} = user) do
    Repo.all(ShelfQueries.shelves_for_user(user) |> preload([:author, items: [:anime]]))
  end

  @doc """
  Gets a single shelf.

  Raises `Ecto.NoResultsError` if the Shelf does not exist.

  ## Examples

      iex> get_shelf!(123)
      %Shelf{}

      iex> get_shelf!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shelf!(id) do
    Repo.get!(Shelf, id)
    |> Repo.preload([:author, items: [:anime]])
  end

  def get_user_shelf_for_anime(%User{} = user, %Anime{} = anime) do
    Repo.get_by(ShelfItem, author_id: user.id, anime_id: anime.id)
  end


  @doc """
  Creates a shelf.

  ## Examples

      iex> create_shelf(%{field: value})
      {:ok, %Shelf{}}

      iex> create_shelf(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shelf(attrs \\ %{}) do
    %Shelf{}
    |> Shelf.changeset(attrs)
    |> Repo.insert()
  end

  def create_shelf_item(attrs, current_user) do
    %ShelfItem{}
    |> ShelfItem.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:author, current_user)
    |> Repo.insert()
  end

  def move_shelf_item(%Anime{} = anime, %User{} = user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_previous_shelf, ShelfQueries.shelf_for_user_and_anime(anime, user))
    |> Ecto.Multi.insert(:insert_new_shelf,
      %ShelfItem{}
      |> ShelfItem.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:author, user)
    )
    |> Repo.transaction()
  end

  @doc """
  Updates a shelf.

  ## Examples

      iex> update_shelf(shelf, %{field: new_value})
      {:ok, %Shelf{}}

      iex> update_shelf(shelf, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shelf(%Shelf{} = shelf, attrs) do
    shelf
    |> Shelf.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shelf.

  ## Examples

      iex> delete_shelf(shelf)
      {:ok, %Shelf{}}

      iex> delete_shelf(shelf)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shelf(%Shelf{} = shelf) do
    Repo.delete(shelf)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shelf changes.

  ## Examples

      iex> change_shelf(shelf)
      %Ecto.Changeset{data: %Shelf{}}

  """
  def change_shelf(%Shelf{} = shelf, attrs \\ %{}) do
    Shelf.changeset(shelf, attrs)
  end

  def change_shelf_item(%ShelfItem{} = shelf, attrs \\ %{}) do
    ShelfItem.changeset(shelf, attrs)
  end
end
