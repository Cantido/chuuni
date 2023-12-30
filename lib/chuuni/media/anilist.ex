defmodule Chuuni.Media.Anilist do
  alias Chuuni.Media

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
            id
            idMal
            description
            title {
              romaji
              english
              native
            }
            coverImage {
              extraLarge
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
    %{perPage: limit, page: 1}
    )

    resp.body["data"]["Page"]["media"]
  end

  def import_anime_response(resp) do
    params = response_to_anime_params(resp)

    with {:ok, anime} <- Media.create_anime(params),
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

  defp id_to_string(nil), do: nil
  defp id_to_string(i), do: Integer.to_string(i)
end
