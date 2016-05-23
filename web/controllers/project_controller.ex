defmodule Wall.ProjectController do
  use Wall.Web, :controller

  alias Wall.Project

  def index(conn, _params) do
    projects = Repo.all(Project)
    render(conn, "index.json", projects: projects)
  end
end
