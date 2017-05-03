defmodule Micountry.country do
  use Micountry.Web, :model

  schema "countrys" do
    field :id_country, :integer
  
    has_many :country_offer, Sling.country_offer
    many_to_many :offer, Sling.offer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id_country])
  end

end