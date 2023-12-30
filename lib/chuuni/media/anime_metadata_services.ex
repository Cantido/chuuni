defmodule Chuuni.Media.AnimeMetadataServices do
  use Chuuni.Schema
  alias Chuuni.Media.AnimeMetadataServices

  embedded_schema do
    field :anilist, :string
    field :myanimelist, :string
  end

  @doc false
  def changeset(%AnimeMetadataServices{} = anime_metadata_services, attrs) do
    anime_metadata_services
    |> cast(attrs, [:anilist, :myanimelist])
    |> validate_format(:anilist, ~r/\d{1,9}/)
    |> validate_format(:myanimelist, ~r/\d{1,16}/)
  end
end
