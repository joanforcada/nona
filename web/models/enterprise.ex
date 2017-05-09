defmodule Tino.Enterprise do
  use Tino.Web, :model

  schema "enterprises" do
    field :name, :integer
    field :permalink, :integer
    field :code, :string

    belongs_to :country, Tino.Country
    belongs_to :currency, Tino.Currency
    has_many :purchase_orders, Tino.PurchaseOrder
    has_many :campaigns, Tino.Campaign

    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :code, :country_id, :currency_id])
    # |> validate_required([:user_id, :room_id])
  end

end
