defmodule Chuuni.Reviews.Recommendation do
  use Chuuni.Schema

  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime

  schema "recommendations" do
    belongs_to :anime, Anime
    belongs_to :recommended, Anime
    belongs_to :user, User

    field :vote, Ecto.Enum, values: [:up, :down]

    timestamps()
  end

  def changeset(model, params) do
    model
    |> cast(params, [:anime_id, :recommended_id, :user_id, :vote])
    |> validate_required([:vote])
    |> assoc_constraint(:anime)
    |> assoc_constraint(:recommended)
    |> assoc_constraint(:user)
  end
end
