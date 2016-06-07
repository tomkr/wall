defmodule Wall.NotificationChannel do
  use Wall.Web, :channel

  def join("notifications:lobby", payload, socket) do
    if authorized?(payload, socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
      {:ok, _user_id} ->
        true
      {:error, _reason} ->
        false
    end
  end

  defp authorized?(_payload, _socket) do
    false
  end
end
