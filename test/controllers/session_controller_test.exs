defmodule Wall.SessionControllerTest do
  use Wall.ConnCase

  test "shows a sign in form" do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Sign in using your Google Apps account"
  end

  test "logs the user in when providing right credentials" do
    conn = post conn, session_path(conn, :create, %{"username" => "test", "password" => "test"})
    assert redirected_to(conn) == "/"
  end

  test "sets a flash error when providing the wrong credentials" do
    conn = post conn, session_path(conn, :create, %{"username" => "bad", "password" => "bad"})
    assert get_flash(conn)["error"] == "An error occured: Invalid username or password."
  end

  test "sets a flash error when providing no credentials at all" do
    conn = post conn, session_path(conn, :create)
    assert get_flash(conn)["error"] == "An error occured: No credentials provided."
  end

  test "redirects back to the home page after logging out" do
    conn = get conn, session_path(conn, :delete)
    assert redirected_to(conn) =~ "/"
  end

  test "sets a flash confirmation after logging out" do
    conn = get conn, session_path(conn, :delete)
    assert get_flash(conn)["error"] == "You were logged out."
  end
end
