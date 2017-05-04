defmodule Tino.PurchaseOrder do
  use Tino.Web, :model

  schema "purchase_orders" do
    field :number, :string
    field :amount, :double

    field :order_type, :integer

    belongs_to :enterprise, Tino.Enterprise
    belongs_to :campaign, Tino.Campaign
    belongs_to :product, Tino.Product
    belongs_to :country, Tino.Country

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :campaign, :product, :enterprise, :amount, :country, :order_type])
  end
end