defmodule Chuuni.Shelves.ShelfQueries do
  alias Chuuni.Accounts.User
  alias Chuuni.Shelves.Shelf
  alias Chuuni.Shelves.ShelfItem

  import Ecto.Query

  def shelves_for_user(%User{} = user) do
    Ecto.assoc(user, :shelves)
  end
end
