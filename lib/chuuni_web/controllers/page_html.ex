defmodule ChuuniWeb.PageHTML do
  use ChuuniWeb, :html

  embed_templates "page_html/*"

  attr :query, :string, default: ""
  attr :local_results, :list, default: []
  attr :anilist_results, :list, default: []

  def search(assigns)

  attr :anime, Chuuni.Media.Anime

  def anime_card(assigns) do
    ~H"""
      <div class="card">
        <a href={~p"/anime/#{@anime}"}>
          <div class="card-image">
            <div class="image is-2by3">
              <img src={~p"/artwork/anime/#{@anime}/cover.png"} />
            </div>
          </div>

          <div class="card-content is-size-7">
            <%= @anime.title.english %>
          </div>
        </a>
      </div>
    """
  end
end
