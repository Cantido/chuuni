defmodule Chuuni.Shelves.ShelfQueries do
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime

  import Ecto.Query

  def shelves_for_user(%User{} = user) do
    Ecto.assoc(user, :shelves)
  end

  def shelf_for_user_and_anime(%Anime{} = anime, %User{} = user) do
    from si in ShelfItem,
      where: [author_id: ^user.id, anime_id: ^anime.id]
  end
end
