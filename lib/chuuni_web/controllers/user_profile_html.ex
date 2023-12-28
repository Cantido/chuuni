defmodule ChuuniWeb.UserProfileHTML do
  use ChuuniWeb, :html

  embed_templates "user_profile_html/*"

  attr :active_tab, :atom
  attr :user, Chuuni.Accounts.User

  attr :rest, :global

  def profile_tabs(assigns)

  attr :review, Chuuni.Reviews.Review

  attr :rest, :global

  def activity_card(assigns)
end
