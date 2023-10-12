defmodule ChuuniWeb.ShelfHTML do
  use ChuuniWeb, :html

  embed_templates "shelf_html/*"

  @doc """
  Renders a shelf form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shelf_form(assigns)
end
