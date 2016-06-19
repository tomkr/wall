defmodule Wall.Account do
  use Wall.Web, :model

  schema "accounts" do
    field :email, :string
    field :family_name, :string
    field :given_name, :string
    field :hd, :string
    field :name, :string
    field :picture, :string
    field :sub, :string

    timestamps
  end

  @required_fields ~w(email hd)
  @optional_fields ~w(family_name given_name name picture sub)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:email)
  end


  def get_or_create(attrs = %{"email" => email}) do
    case Wall.Repo.get_by(Wall.Account, email: email) do
      nil ->
        result =
          %Wall.Account{}
          |> Wall.Account.changeset(attrs)
          |> Wall.Repo.insert()
        case result do
          {:ok, account} -> account
          error -> error
        end
      account ->
        account
    end
  end
end
