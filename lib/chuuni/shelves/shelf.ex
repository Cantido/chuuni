defmodule Chuuni.Shelves.Shelf do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chuuni.Accounts.User
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Media.Anime

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shelves" do
    field :title, :string
    belongs_to :author, User
    has_many :items, ShelfItem
    many_to_many :anime, Anime, join_through: ShelfItem
    timestamps()
  end

  @doc false
  def changeset(shelf, attrs) do
    shelf
    |> cast(attrs, [:title, :author_id])
    |> validate_required([:title])
    |> assoc_constraint(:author)
    |> cast_assoc(:items)
    |> validate_length(:items, max: 1000)
  end
end
