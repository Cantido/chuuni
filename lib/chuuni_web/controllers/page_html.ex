defmodule ChuuniWeb.PageHTML do
  use ChuuniWeb, :html

  embed_templates "page_html/*"

  attr :query, :string, default: ""
  attr :local_results, :list, default: []
  attr :anilist_results, :list, default: []

  def search(assigns)
end
