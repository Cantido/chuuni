defmodule ChuuniWeb.RecommendationHTML do
  use ChuuniWeb, :html

  embed_templates "recommendation_html/*"

  attr :title, :string
  attr :image, :string
  attr :description, :string

  slot :actions

  def search_result(assigns)

  attr :anime, Chuuni.Media.Anime
  attr :rating_summary, Chuuni.Reviews.RatingSummary

  attr :rest, :global

  slot :header

  def anime_column(assigns)

  attr :like_href, :string
  attr :dislike_href, :string
  attr :upvote_count, :integer
  attr :downvote_count, :integer
  attr :vote, :atom

  def vote_buttons(assigns)
end
