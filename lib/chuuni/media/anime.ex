defmodule Chuuni.Media.Anime do
  use Ecto.Schema

  alias Chuuni.Media.AnimeTitles
  alias Chuuni.Media.AnimeMetadataServices
  alias Chuuni.Reviews.Review
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Shelves.Shelf

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "anime" do
    field :cover, :binary, virtual: true
    embeds_one :title, AnimeTitles, on_replace: :update
    field :description, :string
    embeds_one :external_ids, AnimeMetadataServices, on_replace: :update

    has_many :reviews, Review
    has_many :shelf_items, ShelfItem
    has_many :shelves, through: [:shelf_items, :shelf]

    timestamps()
  end

  @doc false
  def changeset(anime, attrs) do
    anime
    |> cast(attrs, [:description])
    |> cast_embed(:title)
    |> cast_embed(:external_ids)
    |> validate_required([:title])
    |> unique_constraint(:external_ids, name: "anime__external_ids____anilist_index")
  end
end
