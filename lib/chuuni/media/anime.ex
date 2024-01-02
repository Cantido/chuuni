defmodule Chuuni.Media.Anime do
  use Chuuni.Schema

  alias Chuuni.Media.AnimeTitles
  alias Chuuni.Media.AnimeMetadataServices
  alias Chuuni.Media.FuzzyDate
  alias Chuuni.Shelves.ShelfItem
  alias Chuuni.Reviews.Recommendation
  alias Chuuni.Reviews.Review

  schema "anime" do
    field :cover, :binary, virtual: true
    embeds_one :title, AnimeTitles, on_replace: :update
    field :description, :string
    embeds_one :external_ids, AnimeMetadataServices, on_replace: :update

    embeds_one :start_date, FuzzyDate
    embeds_one :stop_date, FuzzyDate

    has_many :reviews, Review
    has_many :shelf_items, ShelfItem
    has_many :shelves, through: [:shelf_items, :shelf]

    has_many :recommendations, Recommendation

    timestamps()
  end

  @doc false
  def changeset(anime, attrs) do
    anime
    |> cast(attrs, [:description])
    |> cast_embed(:title)
    |> cast_embed(:external_ids)
    |> cast_embed(:start_date)
    |> cast_embed(:stop_date)
    |> validate_required([:title])
    |> unique_constraint(:external_ids, name: "anime__external_ids____anilist_index")
  end
end
