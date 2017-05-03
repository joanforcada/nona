defmodule Mipurchase_orders.purchase_order do
  use Mipurchase_orders.Web, :model

  schema "purchase_orders" do
    field :number, :interger
    field :campaing, :integer
    field :product, :string
    field :enterprise, :string
    field :amount, :string
    field :country, :string
    field :order_type, :integer
    
    belongs_to :enterprise, Sling.enterprise
   
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:campaing, :product, :enterprise, :amount, :country, :order_type])
  end
end