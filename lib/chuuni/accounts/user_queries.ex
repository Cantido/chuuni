defmodule Chuuni.Accounts.UserQueries do
  alias Chuuni.Accounts.User
  import Ecto.Query

  def user_by_id(id) do
    from u in User, where: [id: ^id]
  end

  def follower_count(query) do
    from u in query,
      join: f in assoc(u, :followers),
      select: count(f)
  end

  def following_count(query) do
    from u in query,
      join: f in assoc(u, :following),
      select: count(f)
  end
end
