defmodule Tino.PurchaseOrder do
  use Tino.Web, :model

  schema "purchase_orders" do
    field :number, :string
    field :description, :string
    field :amount, :float
    field :order_type, :integer

    belongs_to :enterprise, Tino.Enterprise
    belongs_to :campaign, Tino.Campaign
    belongs_to :product, Tino.Product
    belongs_to :country, Tino.Country
    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :amount, :order_type, :created_ts, :updated_ts])
  #  |> cast_assoc(params, [:campaign, :enterprise, :product, :country])
  end
end
