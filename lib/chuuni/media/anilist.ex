defmodule Chuuni.Media.Anilist do
  alias Chuuni.Media
  alias Chuuni.Media.Anime

  def register_fragments do
    Neuron.Fragment.register("""
      AnimeParts on Media {
        id
        idMal
        title {
          romaji
          english
          native
        }
        coverImage {
          medium
          large
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
    """)
  end

  def import_mal_anime(mal_ids, page, page_size) when is_list(mal_ids) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($idMal_in: [Int], $page: Int, $perPage: Int) {
        Page(page: $page, perPage: $perPage) {
          media (idMal_in: $idMal_in, type: ANIME, sort: ID) {
            ...AnimeParts
          }
        }
      }
      """,
    %{idMal_in: mal_ids, perPage: page_size, page: page}
    )

    Enum.map(resp.body["data"]["Page"]["media"], fn media ->
      {:ok, anime} = import_anime_response(media)
      anime
    end)
    |> then(fn anime -> {:ok, anime} end)
  end

  def import_mal_anime(mal_id) when is_integer(mal_id) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($idMal: Int) {
        Media (idMal: $idMal, type: ANIME) {
          ...MediaParts
        }
      }
      """,
    %{idMal: mal_id}
    )

    import_anime_response(resp.body["data"]["Media"])
  end

  def import_anilist_anime(anilist_id) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($id: Int) {
        Media (id: $id, type: ANIME) {
          ...AnimeParts
        }
      }
      """,
    %{id: anilist_id}
    )

    media = resp.body["data"]["Media"]

    import_anime_response(media)
  end

  def search(query, opts \\ [])

  def search(query, _opts) when byte_size(query) <= 3, do: []

  def search(query, opts) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)
    id_not_in = Keyword.get(opts, :id_not_in, [])

    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($search: String, $perPage: Int, $page: Int, $id_not_in: [Int]) {
        Page(page: $page, perPage: $perPage) {
          pageInfo {
            total
            perPage
          }
          media(search: $search, id_not_in: $id_not_in, type: ANIME, sort: FAVOURITES_DESC) {
            ...AnimeParts
            studios(sort: NAME) {
              nodes {
                name
              }
            }
          }
        }
      }
    """,
    %{search: query, perPage: per_page, page: page, id_not_in: id_not_in}
    )

    resp.body["data"]["Page"]["media"]
  end

  def trending_anime(limit) do
    Neuron.Config.set(url: "https://graphql.anilist.co")

    {:ok, resp} = Neuron.query("""
      query ($perPage: Int, $page: Int) {
        Page(page: $page, perPage: $perPage) {
          pageInfo {
            total
            perPage
          }
          media(type: ANIME, sort: TRENDING_DESC) {
            ...AnimeParts
            studios(sort: NAME) {
              nodes {
                name
              }
            }
          }
        }
      }
    """,
    %{perPage: limit, page: 1}
    )

    resp.body["data"]["Page"]["media"]
  end

  def import_anime_response(resp) do
    params = response_to_anime_params(resp)

    with {:ok, anime} <- init_anime(params, resp["id"]),
         {:ok, img_resp} when img_resp.status_code == 200 <- HTTPoison.get(resp["coverImage"]["extraLarge"]),
         cover_path = Media.cover_artwork_path(anime),
         :ok <- File.mkdir_p(Path.dirname(cover_path)),
         :ok <- File.write(cover_path, img_resp.body) do
      {:ok, anime}
    else
      {:error, err} ->
        {:error, {resp, err}}
      err ->
        {:error, {resp, err}}
    end
  end

  defp init_anime(params, anilist_id) do
    case Media.create_anime(params) do
      {:ok, anime} ->
        {:ok, anime}

      {:error, changeset} ->
        if Keyword.has_key?(changeset.errors, :external_ids) do
          Media.fetch_anime_by_anilist_id(anilist_id)
        else
          {:error, changeset}
        end
    end
  end

  defp response_to_anime_params(response) do
    %{
      title: %{
        english: response["title"]["english"],
        romaji: response["title"]["romaji"],
        native: response["title"]["native"]
      },
      description: response["description"],
      start_date: %{
        year: response["startDate"]["year"],
        month: response["startDate"]["month"],
        day: response["startDate"]["day"]
      },
      stop_date: %{
        year: response["endDate"]["year"],
        month: response["endDate"]["month"],
        day: response["endDate"]["day"]
      },
      external_ids: %{
        anilist: id_to_string(response["id"]),
        myanimelist: id_to_string(response["idMal"])
      }
    }
  end

  def response_to_anime_struct(response) do
    struct!(Anime, response_to_anime_params(response))
  end

  defp id_to_string(nil), do: nil
  defp id_to_string(i), do: Integer.to_string(i)
end
