defmodule Wall.Router do
  use Wall.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Wall do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/ping", PageController, :ping
  end

  scope "/api", Wall do
    pipe_through :api
    resources "/projects", ProjectController, only: [:index]
    resources "/events", EventController, only: [:create]
  end
end
