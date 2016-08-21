defmodule Wall.Router do
  use Wall.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Wall.Auth, repo: Wall.Repo
    plug :put_account_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Wall do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/ping", PageController, :ping
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete
    get "/auth/google/callback", SessionController, :create
  end

  scope "/api", Wall do
    pipe_through :api

    resources "/projects", ProjectController, only: [:index, :create, :delete, :update] do
      get "/token", TokenController, :show
    end

    post "/events/:token", EventController, :create
  end

  defp put_account_token(conn, _params) do
    if current_account = conn.assigns[:current_account] do
      token = Phoenix.Token.sign(conn, "user socket", current_account.id)
      assign(conn, :account_token, token)
    else
      conn
    end
  end
end
