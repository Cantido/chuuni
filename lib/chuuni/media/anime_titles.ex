defmodule Chuuni.Media.AnimeTitles do
  use Chuuni.Schema
  alias Chuuni.Media.AnimeTitles

  embedded_schema do
    field :native, :string
    field :english, :string
    field :romaji, :string
  end

  @doc false
  def changeset(%AnimeTitles{} = anime_titles, attrs) do
    anime_titles
    |> cast(attrs, [:english, :romaji, :native])
    |> validate_required([:native])
  end
end
