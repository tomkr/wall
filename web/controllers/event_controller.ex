defmodule Wall.EventController do
  use Wall.Web, :controller

  alias Wall.Event

  def index(conn, _params) do
    events = Repo.all(Event)
    render(conn, "index.json", events: events)
  end

  def create(conn, event_params) do
    changeset = Event.changeset(%Event{}, event_params)

    case Repo.insert(changeset) do
      {:ok, event} ->
        conn
        |> put_status(:created)
        |> render("show.json", event: event)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Wall.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
