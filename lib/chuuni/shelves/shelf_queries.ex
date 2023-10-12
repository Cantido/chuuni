defmodule Chuuni.Shelves.ShelfQueries do
  alias Chuuni.Accounts.User

  def shelves_for_user(%User{} = user) do
    Ecto.assoc(user, :shelves)
  end
end
