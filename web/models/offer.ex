defmodule Tino.Offer do
  use Tino.Web, :model

  schema "offers" do
    field :permalink, :integer
    field :budget,  :integer
    field :status,  :string
    field :offer_url,  :string
    field :preview_url,  :string
    field :video_type, :string
    field :vast_version, :integer
    belongs_to :campaign, Tino.Campaign
    belongs_to :product, Tino.Product
    many_to_many :countries, Tino.Country, join_through: "countries_offers"
    many_to_many :purchase_orders, Tino.PurchaseOrder, join_through: "offer_shares", on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:campaign_id, :product_id, :status, :offer_url, :preview_url, :video_type, :vast_version])
  end

end
