defmodule ChuuniWeb.PageHTML do
  use ChuuniWeb, :html

  embed_templates "page_html/*"

  attr :query, :string, default: ""
  attr :local_results, :list, default: []
  attr :anilist_results, :list, default: []

  def search(assigns)

  attr :summary, Chuuni.Reviews.ReviewSummary

  def anime_card(assigns) do
    ~H"""
      <article class="card is-flex is-flex-direction-column" aria-labelledby={"anime-card-#{@summary.anime.id}"} style="height: 21em;">
        <div class="card-image">
          <a href={~p"/anime/#{@summary.anime}"}>
            <div class="image">
              <img
                src={~p"/artwork/anime/#{@summary.anime}/cover.png"}
                alt={@summary.anime.title.english}
              />
            </div>
          </a>
        </div>

        <div class="card-content is-size-7 is-flex is-flex-direction-column is-justify-content-space-between" style="padding: 0.75rem; flex-grow: 1">
          <div id={"anime-card-#{@summary.anime.id}"} style="overflow: hidden;">
            <%= @summary.anime.title.english %>
          </div>
          <div :if={@summary.count}>
            <footer>
              <span class="icon-text">
                <%= if @summary.rating do %>
                  <%= Float.round(@summary.rating, 2) %>
                <% else %>
                  <span aria-hidden="true">
                    ??
                  </span>
                  <span class="is-sr-only">
                    unknown
                  </span>
                <% end %>
                <span class="icon">
                  <img src={~p"/images/bootstrap/star-fill.svg"} alt="rating" />
                </span>
                &nbsp;
                <%= @summary.count %>
                <span class="icon ml-0">
                  <img src={~p"/images/bootstrap/person-fill.svg"} alt="reviews" />
                </span>
              </span>
            </footer>
          </div>
        </div>
      </article>
    """
  end
end
