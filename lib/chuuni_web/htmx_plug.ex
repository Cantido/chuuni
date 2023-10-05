defmodule ChuuniWeb.HTMXPlug do
  use Plug.Builder

  plug :detect_htmx_request

  @doc """
  Extracts HTMX headers into the conn's assigns.
  """
  def detect_htmx_request(conn, _opts) do
    if get_req_header(conn, "hx-request") == ["true"] do
      assign(conn, :htmx, %{
        request: true,
        boosted: get_req_header(conn, "hx-boosted") != [],
        current_url: List.first(get_req_header(conn, "hx-current-url")),
        history_restore_request: get_req_header(conn, "hx-history-restore-request") == ["true"],
        prompt: List.first(get_req_header(conn, "hx-prompt")),
        target: List.first(get_req_header(conn, "hx-target")),
        trigger_name: List.first(get_req_header(conn, "hx-trigger-name")),
        trigger: List.first(get_req_header(conn, "hx-trigger"))
      })
    else
      conn
    end
  end
end
