defmodule Tino.Offer do
  use Tino.Web, :model

  schema "offers" do
    field :name, :string
    field :permalink, :string
    field :status,  :string
    field :offer_url,  :string
    field :preview_url,  :string
    field :video_provider, :integer
    field :vast_version, :integer
    belongs_to :campaign, Tino.Campaign
    belongs_to :product, Tino.Product
    many_to_many :countries, Tino.Country, join_through: "countries_offers"
    many_to_many :purchase_orders, Tino.PurchaseOrder, join_through: "offer_shares", on_delete: :delete_all
    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :permalink, :status, :offer_url, :preview_url, :video_provider, :vast_version, :created_ts, :updated_ts])
    #|> cast_assoc(params, [:campaign_id, :product_id,])
  end

end
