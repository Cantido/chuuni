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
      <div class="card">
        <a href={~p"/anime/#{@summary.anime}"}>
          <div class="card-image">
            <div class="image is-2by3">
              <img src={~p"/artwork/anime/#{@summary.anime}/cover.png"} />
            </div>
          </div>

          <div class="is-size-7 is-flex is-flex-direction-column is-justify-content-space-between" style="height: 7rem; padding: 0.75rem;">
            <p style="overflow: hidden; max-height: 100%"><%= @summary.anime.title.english %></p>
            <div :if={@summary.count}>
              <p class="has-text-grey-light">
                <small>
                  <%= Decimal.round(@summary.rating, 2) %>
                  <span class="fa-solid fa-star" />
                  &nbsp;
                  <%= @summary.count %>
                  <span class="fa-solid fa-user" />
                </small>
              </p>
            </div>
          </div>
        </a>
      </div>
    """
  end
end
