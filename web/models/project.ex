defmodule Wall.Project do
  use Wall.Web, :model

  schema "projects" do
    field :name, :string
    timestamps
    has_many :events, Wall.Event, on_delete: :delete_all
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
