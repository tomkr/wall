defmodule Wall.AuthTest do
  use Wall.ConnCase

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Wall.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate halts when the current account does not exist", %{conn: conn} do
    conn =
      conn
      |> Wall.Auth.authenticate([])
    assert conn.halted
  end

  test "authenticate continues when the current account exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_account, %Wall.Account{})
      |> Wall.Auth.authenticate([])
    refute conn.halted
  end

  test "login puts the account in the session", %{conn: conn} do
    login_conn =
      conn
      |> Wall.Auth.login(%Wall.Account{id: 123})
      |> send_resp(:ok, "")
    next_conn  = get(login_conn, "/")
    assert get_session(next_conn, :account_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:account_id, 123)
      |> Wall.Auth.logout()
      |> send_resp(:ok, "")
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :account_id)
  end

  test "call places account from the session into assigns", %{conn: conn} do
    account = insert_account()
    conn =
      conn
      |> put_session(:account_id, account.id)
      |> Wall.Auth.call(Repo)
    assert conn.assigns.current_account.id == account.id
  end

  test "call with no session sets current_account assign to nil", %{conn: conn} do
    conn = Wall.Auth.call(conn, Repo)
    assert conn.assigns.current_account == nil
  end
end
