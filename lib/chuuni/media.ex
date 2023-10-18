defmodule Chuuni.Media do
  alias Chuuni.Media.Anime
  alias Chuuni.Media.Anime.Query, as: AnimeQuery
  alias Chuuni.Repo

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

  def search_anime(query) do
    Repo.all(AnimeQuery.search(query))
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

  def import_anilist_anime(anilist_id) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($id: Int) {
        Media (id: $id, type: ANIME) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
          }
          description(asHtml: false)
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
      """,
    %{id: anilist_id}
    )

    media = resp.body["data"]["Media"]

    anime_params = %{
      title: %{
        english: media["title"]["english"],
        romaji: media["title"]["romaji"],
        native: media["title"]["native"]
      },
      description: media["description"],
      start_date: %{
        year: media["startDate"]["year"],
        month: media["startDate"]["month"],
        day: media["startDate"]["day"]
      },
      stop_date: %{
        year: media["endDate"]["year"],
        month: media["endDate"]["month"],
        day: media["endDate"]["day"]
      },
      external_ids: %{
        anilist: anilist_id
      }
    }

    with {:ok, anime} <- create_anime(anime_params),
         {:ok, resp} when resp.status_code == 200 <- HTTPoison.get(media["coverImage"]["extraLarge"]),
         cover_path = cover_artwork_path(anime),
         :ok <- File.mkdir_p(Path.dirname(cover_path)),
         :ok <- File.write(cover_path, resp.body) do
      {:ok, anime}
    end
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
