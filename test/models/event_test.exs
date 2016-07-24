defmodule Wall.EventTest do
  use Wall.ModelCase

  alias Wall.Event

  @invalid_attrs %{}

  setup do
    with {:ok, content} = File.read("test/fixtures/github.json"),
         params = Map.put(Poison.decode!(content), "project_id", "1")
    do
      {:ok, params: params}
    end
  end

  test "changeset with valid attributes for Github commit status hook", %{params: params} do
    changeset = Event.changeset(%Event{}, params)
    assert changeset.valid?
  end

  test "changeset with valid attributes for Heroku deployment" do
    changeset = Event.changeset(
      %Event{},
      %{"app" => "myapp",
        "release" => "v12",
        "git_log" => "  * fix specs",
        "head" => "123abc",
        "project_id" => "1"}
    )
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Event.changeset(%Event{}, @invalid_attrs)
    refute changeset.valid?
  end
end
