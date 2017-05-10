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
    get "/campaigns/autocomplete", CampaignController, :autocomplete
    get "/countries/autocomplete", CountryController, :autocomplete
    get "/currencies/autocomplete", CurrencyController, :autocomplete
    get "/offers/autocomplete", OfferController, :autocomplete
    get "/purchase_orders/autocomplete", PurchaseOrderController, :autocomplete
    get "/campaigns/autocomplete", CampaignController, :autocomplete

    resources "/products", ProductController, only: [:create, :update]
    resources "/countries", CountryController, only: [:create, :update]
    resources "/currencies", CurrencyController, only: [:create, :update]
    resources "/offers", OfferController, only: [:create, :update]
    resources "/purchase_orders", PurchaseOrderController, only: [:create, :update]
    resources "/campaigns", CampaignController, only: [:create, :update]

  end


  # Other scopes may use custom stacks.
  # scope "/api", Tino do
  #   pipe_through :api
  # end
end
