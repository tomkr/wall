defmodule Wall.NotificationChannel do
  use Wall.Web, :channel

  def join("notifications:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_out(event, payload, socket) do
    IO.puts "******* sending out notification"
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
