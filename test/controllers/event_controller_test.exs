defmodule Wall.EventControllerTest do
  use Wall.ConnCase

  alias Wall.Event

  setup %{conn: conn} do
    with {:ok, content} = File.read("test/fixtures/github.json"),
         params = Poison.decode!(content)
    do
      {:ok, conn: put_req_header(conn, "accept", "application/json"), params: params}
    end
  end

  test "creates resource and confirms Github commit status hooks", %{conn: conn, params: params} do
    conn = post conn, event_path(conn, :create), params
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Event, %{topic: "ci"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_path(conn, :create), event: %{}
    assert json_response(conn, 422)["errors"] != %{}
  end
end
