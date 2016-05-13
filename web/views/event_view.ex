defmodule Wall.EventView do
  use Wall.Web, :view

  def render("index.json", %{events: events}) do
    %{data: render_many(events, Wall.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Wall.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      topic: event.topic,
      status: event.status,
      date: event.date,
      subtopic: event.subtopic,
      notes: event.notes}
  end
end
