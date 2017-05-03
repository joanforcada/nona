defmodule Tino.CountryOffer do
  use Tino.Web, :model

  schema "countries_offers" do

    belongs_to :offer, Tino.Offer
    belongs_to :country, Tino.Country

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:offer_id, :country_id])
    # |> validate_required([:user_id, :room_id])
    |> unique_constraint(:country_id_offer_id)
  end

end
