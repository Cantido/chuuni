defmodule ChuuniWeb.UserFollowHTML do
  use ChuuniWeb, :html

  embed_templates "user_follow_html/*"

  attr :user, Chuuni.Accounts.User
  attr :follower_count, :integer

  def follower_count(assigns) do
    ~H"""
    <span hx-get={~p"/@#{@user.name}/followers/count"} hx-trigger="follow from:body, unfollow from:body" hx-swap="outerHTML"><%= @follower_count %></span>
    """
  end
end
