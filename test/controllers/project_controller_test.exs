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
end
