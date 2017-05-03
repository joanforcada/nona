defmodule Mienterprise.enterprise do
  use Mienterprise.Web, :model

  schema "enterprise" do
    field :number, :integer
    field :permalink, :integer
  
    has_many :purchase_order, Sling.purchase_order
    has_many :campaing, Sling.campaing

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
end