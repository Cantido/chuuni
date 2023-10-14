defmodule Chuuni.Reviews.Review do
  use Chuuni.Schema

  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime

  schema "reviews" do
    field :rating, :integer
    field :body, :string
    belongs_to :anime, Anime
    belongs_to :author, User

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:anime_id, :rating, :body, :author_id])
    |> assoc_constraint(:author)
    |> assoc_constraint(:anime)
    |> unique_constraint([:author_id, :anime_id])
    |> validate_required([:rating])
    |> validate_inclusion(:rating, 1..10)
  end
end
