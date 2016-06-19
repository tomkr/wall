defmodule Wall.Auth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    account_id = get_session(conn, :account_id)
    cond do
      account = conn.assigns[:current_account] ->
        assign(conn, :current_account, account)
      account = account_id && repo.get(Wall.Account, account_id) ->
        assign(conn, :current_account, account)
      true ->
        assign(conn, :current_account, nil)
    end
  end


  def authenticate(conn, _opts) do
    if conn.assigns.current_account do
      conn
    else
      conn
      |> put_flash(:error, "You need to log in first.")
      |> redirect(to: Wall.Router.Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  def login(conn, account) do
    conn
    |> assign(:current_account, account)
    |> put_session(:account_id, account.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end
end
