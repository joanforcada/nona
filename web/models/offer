defmodule Mioffer.offer do
  use Mioffer.Web, :model

  schema "offers" do
    field :permalink, :integer
    field :campaing, :integer
    field :product, :string
    field :budget,  :integer
    field :status,  :string
    field :tags,    :integer
    field :video_type, :integer
    field :vast_version, :integer
    belongs_to :campaing, Sling.campaing
    belongs_to :product, Sling.product
    many_to_many :country, Sling.country
    has_many    :country_offer, Sling.country_offer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
end