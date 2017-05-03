defmodule Miproduct.product do
  use Miproduct.Web, :model

  schema "products" do
    field :permalink, :integer
 
    has_many :offer, Sling.offer
  
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
end