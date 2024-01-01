defmodule ChuuniWeb.ShelfHTML do
  use ChuuniWeb, :html

  embed_templates "shelf_html/*"

  @doc """
  Renders a shelf form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shelf_form(assigns)

  attr :anime, Chuuni.Media.Anime
  attr :review, Chuuni.Reviews.Review, default: nil
  attr :rest, :global

  slot :actions

  def shelf_item(assigns)

  attr :start_date, :string, default: "unknown"
  attr :stop_date, :string, default: "unknown"

  def fuzzy_date_range(assigns) do
    ~H"""
    <%= (@start_date) %>&ndash;<%= (@stop_date) %>
    """
  end
end
