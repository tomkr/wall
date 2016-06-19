defmodule Wall.Google do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  @user_url "https://www.googleapis.com/plus/v1/people/me/openIdConnect"

  def authorize_url!(params \\ []) do
    params = Keyword.merge(params, hd: Application.get_env(:wall, :oauth)[:domain])
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_or_create_account(oauth_code) do
    case get_access_token!(code: oauth_code) do
      {:ok, google_oauth} ->
        account = Wall.Account.get_or_create(google_oauth)
        {:ok, account}
      error ->
        error
    end
  end

  defp client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:wall, :oauth)[:client_id],
      client_secret: Application.get_env(:wall, :oauth)[:client_secret],
      redirect_uri: Application.get_env(:wall, :oauth)[:redirect_uri],
      site: "https://accounts.google.com",
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url: "https://accounts.google.com/o/oauth2/token"
    ])
  end

  defp get_access_token!(params \\ [], headers \\ []) do
    access_token =
      client()
      |> OAuth2.Client.get_token!(params, headers)
      |> OAuth2.AccessToken.get(@user_url)

    case access_token do
      {:ok, %OAuth2.Response{status_code: 401}} ->
        {:error, :unauthorized}
      {:ok, %OAuth2.Response{status_code: status_code, body: body}} when status_code in 200..299 ->
        {:ok, body}
      {:ok, _response} ->
        {:error, :unknown}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end
end
