defmodule ChuuniWeb.ShelfHTML do
  use ChuuniWeb, :html

  embed_templates "shelf_html/*"

  @doc """
  Renders a shelf form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shelf_form(assigns)

  attr :href, :string, required: true
  attr :target, :string, default: ""
  attr :image, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :start_date, :string, default: "unknown"
  attr :stop_date, :string, default: "unknown"
  attr :studios, :string, default: "unknown"
  attr :rating, :integer, default: nil
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

  attr :shelves, :list, default: []
  attr :items, :list, default: []

  attr :rest, :global

  def shelf(assigns)
end
