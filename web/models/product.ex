defmodule Tino.Product do
  use Tino.Web, :model

  schema "products" do
    field :permalink, :string
    field :name, :string
    field :retribution_model, :integer
    field :code, :string
    field :product_format, :string
    field :product_status, :integer
    field :invoicing_model, :integer

    # has_many :offers, Tino.Offer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :retribution_model, :code, :product_format, :product_status, :invoicing_model])
  end

end
