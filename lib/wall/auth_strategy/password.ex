defmodule Wall.AuthStrategy.Password do
  @behaviour Wall.AuthStrategy

  @moduledoc """
  A fake authentication strategy that logs you in using a fake username
  and password. This might be expanded in the future, but the fake
  username and password help with implementing an authentication solution
  to be used in testing without depending on the outside world (OAuth).
  """

  def call(%{"username" => "test", "password" => "test"}) do
    {:ok, %Wall.Account{id: 1}}
  end

  def call(%{"username" => _username, "password" => _password}) do
    {:error, "Invalid username or password."}
  end

  def call(_) do
    {:error, "No credentials provided."}
  end
end
