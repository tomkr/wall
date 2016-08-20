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
      name: project.name,
      masterBuildStatus: Map.get(project, :master_build_status, nil),
      latestBuildStatus: Map.get(project, :latest_build_status, nil)}
  end
end
