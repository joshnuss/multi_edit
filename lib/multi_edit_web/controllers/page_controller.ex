defmodule MultiEditWeb.PageController do
  use MultiEditWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
