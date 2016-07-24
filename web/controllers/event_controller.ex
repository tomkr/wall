defmodule Wall.EventController do
  use Wall.Web, :controller

  alias Wall.Event

  def create(conn, event_params) do
    case Phoenix.Token.verify(Wall.Endpoint, "token", event_params["token"]) do
      {:ok, project_id} ->
        changeset = Event.changeset(%Event{}, Map.put(event_params, "project_id", project_id))

        case Repo.insert(changeset) do
          {:ok, event} ->
            conn
            |> put_status(:created)
            |> render("show.json", event: event)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(Wall.ErrorView, "errors.json", changeset: changeset)
        end
      {:error, :invalid} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid token"})
    end
  end
end
