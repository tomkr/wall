defmodule Wall.ProjectController do
  use Wall.Web, :controller

  plug :authorize_token

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
          "newProject",
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

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Wall.Project, id)
    changeset = Wall.Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        Wall.Endpoint.broadcast(
          "notifications:lobby",
          "updateProject",
          Wall.ProjectView.render("project.json", %{project: project})
        )
        render(conn, "show.json", project: project)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Wall.ErrorView, "errors.json", %{changeset: changeset})
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Wall.Project, id)
    Repo.delete!(project)
    Wall.Endpoint.broadcast(
      "notifications:lobby",
      "deleteProject",
      Wall.ProjectView.render("project.json", %{project: project})
    )
    send_resp(conn, :no_content, "")
  end

  defp authorize_token(conn, _options) do
    case Phoenix.Token.verify(conn, "user socket", conn.params["token"], max_age: 1209600) do
      {:ok, _user_id} ->
        conn
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> text("")
        |> halt
    end
  end
end
