defmodule Wall.ProjectControllerTest do
  use Wall.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    Repo.insert(%Wall.Project{id: 1, name: "project 1"})
    conn = get conn, project_path(conn, :index)
    assert json_response(conn, 200)["data"] == [
      %{"id" => 1,
        "name" => "project 1",
        "masterBuildStatus" => nil,
        "latestBuildStatus" => nil}
    ]
  end

  test "shows an error when a new project is invalid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: %{}
    assert json_response(conn, 422)["errors"]["name"] == ["can't be blank"]
  end

  test "creates a new project when it is valid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: %{name: "My project"}
    assert %{
      "id" => _,
      "latestBuildStatus" => nil,
      "masterBuildStatus" => nil,
      "name" => "My project"
    } = json_response(conn, 201)["data"]
  end

  test "destroys an existing project", %{conn: conn} do
    Repo.insert(%Wall.Project{id: 1, name: "project 1"})
    assert Repo.aggregate(Wall.Project, :count, :id) == 1
    conn = delete conn, project_path(conn, :delete, 1)
    assert response(conn, 200) == "{}"
    assert Repo.aggregate(Wall.Project, :count, :id) == 0
  end
end
