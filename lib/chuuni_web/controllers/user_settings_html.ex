defmodule ChuuniWeb.UserSettingsHTML do
  use ChuuniWeb, :html

  embed_templates "user_settings_html/*"

  attr :message, :string, required: true

  attr :close_url, :string, default: nil

  def success_message(assigns)

  attr :message, :string, required: true

  attr :close_url, :string, default: nil

  def danger_message(assigns)
end
