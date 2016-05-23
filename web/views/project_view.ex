defmodule Wall.ProjectView do
  use Wall.Web, :view

  def render("index.json", %{projects: projects}) do
    %{data: render_many(projects, Wall.ProjectView, "project.json")}
  end

  def render("show.json", %{project: project}) do
    %{data: render_one(project, Wall.ProjectView, "project.json")}
  end

  def render("project.json", %{project: project}) do
    %{id: project.id,
      name: project.name}
  end
end
