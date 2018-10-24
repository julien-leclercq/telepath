defmodule WebWeb.Router do
  use WebWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Other scopes may use custom stacks.
  scope "/api", WebWeb do
    pipe_through(:api)

    scope "/seedboxes" do
      get("/", Api.SeedboxController, :index)
      post("/", Api.SeedboxController, :create)
      put("/:id", Api.SeedboxController, :update)
      delete("/:id", Api.SeedboxController, :delete)
    end

    get("/torrents", Api.TorrentController, :index)

    get("/tracks", Api.TrackController, :index)
    get("/tracks/:track_id", Api.TrackController, :get_file)
  end

  scope "/", WebWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/*_application_route", PageController, :index)
  end
end
