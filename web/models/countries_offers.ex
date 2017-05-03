defmodule Micountries_offers.CountryOffers do
  use Micountries_offers.Web, :model

  schema "countries_offers" do
       
    belong_to :offer, Sling.offer
    belong_to :country, Sling.country

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

end