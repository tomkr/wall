defmodule Wall.EventView do
  use Wall.Web, :view

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Wall.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      topic: event.topic,
      status: event.status,
      date: event.date,
      subtopic: event.subtopic,
      notes: event.notes,
      projectId: event.project_id}
  end
end
