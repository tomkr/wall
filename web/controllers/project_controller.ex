defmodule Wall.ProjectController do
  use Wall.Web, :controller

  alias Wall.Project

  def index(conn, _params) do
    query = from w in "wall",
      select: %{id: w.id,
                name: w.name,
                master_build_status: w.master_build_status,
                latest_build_status: w.latest_build_status}
    projects = Repo.all(query)
    render(conn, "index.json", projects: projects)
  end
end
