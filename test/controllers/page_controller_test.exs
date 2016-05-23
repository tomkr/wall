defmodule Wall.PageControllerTest do
  use Wall.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Wall!"
  end
end
