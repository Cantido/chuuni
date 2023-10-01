defmodule ChuuniWeb.ReviewHTML do
  use ChuuniWeb, :html

  embed_templates "review_html/*"

  @doc """
  Renders a review form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def review_form(assigns)

  attr :review, Chuuni.Reviews.Review, required: true

  def review_card(assigns)
end
