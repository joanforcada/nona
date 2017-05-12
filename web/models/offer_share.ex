defmodule Tino.OfferShare do
  use Tino.Web, :model

  schema "offer_shares" do

    belongs_to :offer, Tino.Offer
    belongs_to :purchase_order, Tino.PurchaseOrder
    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:offer_id, :purchase_order_id, :created_ts, :updated_ts])
    # |> validate_required([:user_id, :room_id])
    |> unique_constraint(:offer_id_purchase_order_id)
  end

end
