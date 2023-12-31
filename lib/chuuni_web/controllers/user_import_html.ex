defmodule ChuuniWeb.UserImportHTML do
  use ChuuniWeb, :html

  embed_templates "user_import_html/*"

  attr :success_message, :string, default: nil
  attr :danger_message, :string, default: nil

  def mal_form(assigns)
end
