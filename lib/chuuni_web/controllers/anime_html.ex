defmodule ChuuniWeb.AnimeHTML do
  use ChuuniWeb, :html

  alias Chuuni.Media.Anime

  embed_templates "anime_html/*"

  attr :href, :string, required: true
  attr :target, :string, default: ""
  attr :image, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :start_date, :string
  attr :stop_date, :string
  attr :studios, :string, required: true
  attr :rest, :global

  slot :actions

  def search_result(assigns) do
    ~H"""
    <div class="media" {@rest}>
      <figure class="media-left">
        <p class="image is-128x128 is-2by3">
          <img src={@image} />
        </p>
      </figure>
      <div class="media-content">
        <div class="block">
          <div class="title is-5"><.link href={@href} target={@target} rel="nofollow noopener noreferrer"><%= (@title) %></.link></div>
          <div class="subtitle is-7"><%= (@subtitle) %></div>
        </div>

        <div class="block">
          <p><strong>Aired:</strong> <.fuzzy_date_range start_date={@start_date} stop_date={@stop_date} /></p>
          <p><strong>Studios:</strong> <%= (@studios) %></p>
        </div>

        <div class="block">
          <div><%= render_slot(@actions) %></div>
        </div>
      </div>
    </div>
    """
  end

  attr :start_date, :string, default: "unknown"
  attr :stop_date, :string, default: "unknown"

  def fuzzy_date_range(assigns) do
    ~H"""
    <%= (@start_date) %>&ndash;<%= (@stop_date) %>
    """
  end

  attr :shelves, :list, required: true
  attr :anime, Anime, required: true
  attr :current_shelf, :string, default: nil
  attr :success_message, :string, default: nil
  attr :error_message, :string, default: nil

  def shelf_select(assigns)
end
