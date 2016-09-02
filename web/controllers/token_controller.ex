defmodule Wall.TokenController do
  use Wall.Web, :controller

  plug :authorize_token

  def show(conn, %{"project_id" => project_id}) do
    token = Phoenix.Token.sign(conn, "token", project_id)
    |> Base.url_encode64
    conn
    |> json(%{token: token})
  end

  defp authorize_token(conn, _options) do
    case Phoenix.Token.verify(conn, "user socket", conn.params["token"], max_age: 1209600) do
      {:ok, _user_id} ->
        conn
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> text("")
        |> halt
    end
  end
end
