defmodule Wall.TestHelpers do
  def insert_account(attrs \\ %{}) do
    changes = Dict.merge(
      %{email: "john@cleese.net",
        hd: "cleese.net"
      },
      attrs
    )

    %Wall.Account{}
    |> Wall.Account.changeset(changes)
    |> Wall.Repo.insert!()
  end
end
