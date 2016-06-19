defmodule Wall.PageControllerTest do
  use Wall.ConnCase

  setup %{conn: conn} do
    conn = assign(conn, :current_account, %Wall.Account{id: 1})
    {:ok, %{conn: conn}}
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Wall!"
  end
end
