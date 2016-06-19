defmodule Wall.PageController do
  use Wall.Web, :controller

  plug :authenticate when action in [:index]

  def index(conn, _params) do
    render conn, "index.html"
  end
end
