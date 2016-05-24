# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wall.Repo.insert!(%Wall.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Wall.Repo.transaction fn ->
  projects =
    for n <- 1..4, do: Wall.Repo.insert!(%Wall.Project{name: "Project #{n}"})

  for n <- 1..6, pid <- Enum.map(projects, &(&1.id)) do
    Wall.Repo.insert!(
      %Wall.Event{
        payload: %{},
        topic: "ci",
        status: Enum.random(["success", "failed", "pending"]),
        date: %Ecto.DateTime{year: 2016, month: 5, day: 14, hour: n, min: 23, sec: 33},
        subtopic: Enum.random(["master", "feature-1", "feature-2"]),
        notes: "some notes",
        project_id: pid})
  end
end
