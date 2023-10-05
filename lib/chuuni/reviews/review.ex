defmodule Chuuni.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chuuni.Accounts.User
  alias Chuuni.Media.Anime

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts type: :utc_datetime
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
