defmodule Wall.NotificationChannelTest do
  use Wall.ChannelCase

  alias Wall.NotificationChannel

  setup do
    token = Phoenix.Token.sign(@endpoint, "user socket", "foobar")
    {:ok, _, socket} =
      socket("user_id", %{foo: "bar"})
      |> subscribe_and_join(NotificationChannel, "notifications:lobby", %{"token" => token})

    {:ok, socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
