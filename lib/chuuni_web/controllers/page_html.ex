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
      <article class="card" aria-labelledby={"anime-card-#{@summary.anime.id}"}>
        <a href={~p"/anime/#{@summary.anime}"}>
          <div class="card-image">
            <div class="image">
              <img
                src={~p"/artwork/anime/#{@summary.anime}/cover.png"}
                alt={@summary.anime.title.english}
              />
            </div>
          </div>

          <div class="is-size-7 is-flex is-flex-direction-column is-justify-content-space-between" style="height: 7rem; padding: 0.75rem;">
            <header id={"anime-card-#{@summary.anime.id}"} style="overflow: hidden; max-height: 100%">
              <%= @summary.anime.title.english %>
            </header>
            <div :if={@summary.count}>
              <footer>
                <span class="icon-text">
                  <%= if @summary.rating do %>
                    <%= Decimal.round(@summary.rating, 2) %>
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
        </a>
      </article>
    """
  end
end
