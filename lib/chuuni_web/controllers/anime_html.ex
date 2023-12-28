defmodule ChuuniWeb.AnimeHTML do
  alias Chuuni.Media.FuzzyDate
  use ChuuniWeb, :html

  alias Chuuni.Media.Anime

  embed_templates "anime_html/*"

  attr :href, :string, required: true
  attr :target, :string, default: ""
  attr :image, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :start_date, FuzzyDate, default: nil
  attr :stop_date, FuzzyDate, default: nil
  attr :studios, :string, required: true
  attr :rest, :global

  slot :actions

  def search_result(assigns) do
    ~H"""
    <article class="media box" aria-label={@title || @subtitle} {@rest}>
      <div class="media-left">
        <div class="image" style="max-width: 8em;">
          <img src={@image} alt={@title} />
        </div>
      </div>
      <div class="media-content">
        <div class="block">
          <div class="title is-5"><.link href={@href} target={@target} rel="nofollow noopener noreferrer"><%= (@title || @subtitle) %></.link></div>
          <div class="subtitle is-7"><%= (@subtitle) %></div>
        </div>

        <div class="block">
          <p><span class="has-text-weight-bold">Aired:</span> <.fuzzy_date_range start_date={@start_date} stop_date={@stop_date} /></p>
          <p><span class="has-text-weight-bold">Studios:</span> <%= (@studios) %></p>
        </div>

        <div class="block">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </article>
    """
  end

  attr :date, Chuuni.Media.FuzzyDate

  attr :rest, :global

  def fuzzy_date(assigns) do
    if is_nil(assigns.date) or is_nil(assigns.date.year) do
      ~H"<span>unknown</span>"
    else
      datestr = FuzzyDate.to_iso8601(assigns.date)

      assigns = assign(assigns, :datestr, datestr)
      ~H"""
      <time {@rest}><%= @datestr %></time>
      """
    end
  end

  attr :start_date, Chuuni.Media.FuzzyDate
  attr :stop_date, Chuuni.Media.FuzzyDate

  attr :rest, :global

  def fuzzy_date_range(assigns) do
      ~H"""
      <span {@rest}><.fuzzy_date date={@start_date} />/<.fuzzy_date date={@stop_date} /></span>
      """
  end

  attr :shelves, :list, required: true
  attr :anime, Anime, required: true
  attr :current_shelf, :string, default: nil
  attr :success_message, :string, default: nil
  attr :error_message, :string, default: nil

  def shelf_select(assigns)
end
