defmodule Wall.AuthStrategy.Google do
  @behaviour Wall.AuthStrategy

  @moduledoc """
  Special authentication strategy using OAuth2 to request authentication through
  Google. It will always redirect you to Google to sign in, unless we provide a
  code (from the callback we get from Google) that we can use to sign in the
  user.
  """

  def call(%{"code" => code}) do
    Wall.Google.get_or_create_account(code)
  end

  def call(_) do
    {:redirect, Wall.Google.authorize_url!(scope: "email profile")}
  end
end
