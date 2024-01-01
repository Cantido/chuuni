defmodule Chuuni.Media do
  alias Chuuni.Media.Anime
  alias Chuuni.Media.Anime.Query, as: AnimeQuery
  alias Chuuni.Repo

  import Ecto.Query

  @doc """
  Returns the filesystem path that artwork is stored in.
  """
  def artwork_path do
    Application.fetch_env!(:chuuni, :artwork_path)
  end

  @doc """
  Returns the filesystem path for the entity's cover artwork.
  """
  def cover_artwork_path(%Anime{id: id}) do
    Path.join([artwork_path(), "anime", id, "cover.png"])
  end

  @doc """
  Returns the list of anime.

  ## Examples

      iex> list_anime()
      [%Anime{}, ...]

  """
  def list_anime do
    Repo.all(Anime)
  end

  def count_anime do
    Repo.aggregate(Anime, :count)
  end

  def new_anime(limit) do
    Repo.all(
      from a in Anime,
      order_by: [desc: :inserted_at],
      limit: ^limit
    )
  end

  def search_anime(""), do: []

  def search_anime(query) do
    Repo.all(AnimeQuery.search(query))
  end

  def search_anilist(""), do: []

  def search_anilist(query) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($search: String, $perPage: Int, $page: Int) {
        Page(page: $page, perPage: $perPage) {
          pageInfo {
            total
            perPage
          }
          media(search: $search, type: ANIME, sort: FAVOURITES_DESC) {
            id
            title {
              romaji
              english
              native
            }
            coverImage {
              large
            }
            studios(sort: NAME) {
              nodes {
                name
              }
            }
            startDate {
              year
              month
              day
            }
            endDate {
              year
              month
              day
            }
          }
        }
      }
    """,
    %{search: query, perPage: 10, page: 1}
    )

    resp.body["data"]["Page"]["media"]
  end

  @doc """
  Gets a single anime.

  Raises `Ecto.NoResultsError` if the Anime does not exist.

  ## Examples

      iex> get_anime!(123)
      %Anime{}

      iex> get_anime!(456)
      ** (Ecto.NoResultsError)

  """
  def get_anime!(id), do: Repo.get!(Anime, id)

  def get_anime_by_anilist_id(anilist_id) do
    Repo.one(
      from a in Anime,
      where: a.external_ids["anilist"] == ^anilist_id
    )
  end

  @doc """
  Creates a anime.

  ## Examples

      iex> create_anime(%{field: value})
      {:ok, %Anime{}}

      iex> create_anime(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_anime(attrs \\ %{}) do
    %Anime{}
    |> Anime.changeset(attrs)
    |> Repo.insert()
  end



  @doc """
  Updates a anime.

  ## Examples

      iex> update_anime(anime, %{field: new_value})
      {:ok, %Anime{}}

      iex> update_anime(anime, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_anime(%Anime{} = anime, attrs) do
    anime
    |> Anime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a anime.

  ## Examples

      iex> delete_anime(anime)
      {:ok, %Anime{}}

      iex> delete_anime(anime)
      {:error, %Ecto.Changeset{}}

  """
  def delete_anime(%Anime{} = anime) do
    cover_path = cover_artwork_path(anime)
    _ = File.rm(cover_path)
    Repo.delete(anime)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking anime changes.

  ## Examples

      iex> change_anime(anime)
      %Ecto.Changeset{data: %Anime{}}

  """
  def change_anime(%Anime{} = anime, attrs \\ %{}) do
    Anime.changeset(anime, attrs)
  end

  @doc """
  Replaces an anime's cover image on the filesystem.
  """
  def replace_anime_cover(%Anime{} = anime, new_cover_path) do
    cover_path = cover_artwork_path(anime)

    File.cp(new_cover_path, cover_path)
  end
end
