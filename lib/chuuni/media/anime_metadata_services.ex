defmodule Chuuni.Media.AnimeMetadataServices do
  use Chuuni.Schema
  alias Chuuni.Media.AnimeMetadataServices

  embedded_schema do
    field :anilist, :string
  end

  @doc false
  def changeset(%AnimeMetadataServices{} = anime_metadata_services, attrs) do
    anime_metadata_services
    |> cast(attrs, [:anilist])
    |> validate_format(:anilist, ~r/\d{1,9}/)
  end
end
