defmodule Wall.ProjectController do
  use Wall.Web, :controller

  def index(conn, _params) do
    query = from w in "wall",
      select: %{id: w.id,
                name: w.name,
                master_build_status: w.master_build_status,
                latest_build_status: w.latest_build_status}
    projects = Repo.all(query)
    render(conn, "index.json", projects: projects)
  end

  def create(conn, %{"project" => project_params}) do
    project = Wall.Project.changeset(%Wall.Project{}, project_params)
    case Repo.insert(project) do
      {:ok, project} ->
        Wall.Endpoint.broadcast(
          "notifications:lobby",
          "notification",
          Wall.ProjectView.render("project.json", %{project: project})
        )
        conn
        |> put_status(:created)
        |> render("show.json", project: project)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Wall.ErrorView, "errors.json", %{changeset: changeset})
    end
  end
end
