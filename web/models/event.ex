defmodule Wall.Event do
  use Wall.Web, :model

  schema "events" do
    field :payload, :map
    field :topic, :string
    field :status, :string
    field :date, Ecto.DateTime
    field :subtopic, :string
    field :notes, :string
    timestamps
    belongs_to :project, Wall.Project
  end

  @required_fields ~w(payload topic status date project_id)
  @optional_fields ~w(subtopic notes)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(
        model,
        %{
          "context" => "continuous-integration/" <> _,
          "branches" => [%{"name" => branch} | _],
          "state" => status,
          "created_at" => date,
          "description" => notes,
          "project_id" => project_id
        } = params
      ) do
    model
    |> changeset(%{
      payload: params,
      topic: "ci",
      subtopic: branch,
      status: status,
      date: date,
      notes: notes,
      project_id: project_id
    })
  end

  def changeset(
        model,
        %{
          "app" => app,
          "release" => release,
          "git_log" => "  * " <> message,
          "head" => head,
          "project_id" => project_id
        } = params
      ) do
    model
    |> changeset(%{
      payload: params,
      topic: "deployment",
      subtopic: app,
      status: "deployed",
      date: "2016-05-01 12:00:00",
      notes: "#{message} (#{release}, #{head})",
      project_id: project_id
    })
  end

  def changeset(model, params) when is_map(params) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:project_id)
  end

  def changeset(model) do
    changeset(model, :empty)
  end
end
