defmodule Tino.Router do
  use Tino.Web, :router

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

  scope "/", Tino do
    pipe_through :browser # Use the default browser stack
    get "/ping", PingController, :ping

    get "/", PageController, :index

    get "/products/autocomplete", ProductController, :autocomplete
    get "/countries/autocomplete", CountryController, :autocomplete
    get "/currencies/autocomplete", CurrencyController, :autocomplete

  end


  # Other scopes may use custom stacks.
  # scope "/api", Tino do
  #   pipe_through :api
  # end
end
