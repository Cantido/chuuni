defmodule ChuuniWeb.UserSessionHTML do
  use ChuuniWeb, :html

  embed_templates "user_session_html/*"

  attr :close_url, :string, default: nil

  def success_message(assigns)


  attr :close_url, :string, default: nil

  def error_message(assigns)

  attr :error_message, :string, default: nil

  def log_in_form(assigns)
end
