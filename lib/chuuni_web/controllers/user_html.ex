defmodule ChuuniWeb.UserHTML do
  use ChuuniWeb, :html

  embed_templates "user_html/*"

  attr :close_url, :string, default: nil

  def success_message(assigns)


  attr :close_url, :string, default: nil

  def error_message(assigns)

end
