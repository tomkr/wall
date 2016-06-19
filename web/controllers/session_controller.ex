defmodule Wall.SessionController do
  use Wall.Web, :controller

  @authstrategy Application.get_env(:wall, :authstrategy)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, params) do
    login_or_error(conn, @authstrategy.call(params))
  end

  def delete(conn, _params) do
    conn
    |> Wall.Auth.logout()
    |> put_flash(:error, "You were logged out.")
    |> redirect(to: page_path(conn, :index))
  end

  defp login_or_error(conn, {:redirect, url}) do
    conn
    |> redirect(external: url)
  end

  defp login_or_error(conn, {:ok, account}) do
    conn
    |> Wall.Auth.login(account)
    |> redirect(to: page_path(conn, :index))
  end

  defp login_or_error(conn, {:error, reason}) do
    conn
    |> put_flash(:error, "An error occured: #{reason}")
    |> redirect(to: session_path(conn, :new))
  end
end
