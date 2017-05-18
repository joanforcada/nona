defmodule Tino.PurchaseOrder do
  use Tino.Web, :model

  #Fields which to look for when performing autocomplete
  @autocomplete_fields  ~w(number description)a
  # Fields to select from the database (for autocomplete only (for now))
  @select_fields ~w(id number description)a

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
    |> cast(params, [:number, :description, :amount, :order_type, :created_ts, :updated_ts])
  #  |> cast_assoc(params, [:campaign, :enterprise, :product, :country])
  end

  def autocomplete_fields do
    @autocomplete_fields
  end

  def select_fields do
    @select_fields
  end
end
