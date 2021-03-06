defmodule Tino.Product do
  use Tino.Web, :model

  @autocomplete_fields ~w(name code product_format)a
  @select_fields ~w(id name code)a

  schema "products" do
    field :name, :string
    field :retribution_model, :integer
    field :code, :string
    field :product_format, :string
    field :product_status, :integer
    field :invoicing_model, :integer
    field :created_ts, :integer
    field :updated_ts, :integer

    # has_many :offers, Tino.Offer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :retribution_model, :code, :product_format, :product_status, :invoicing_model, :created_ts, :updated_ts])
  end

  def autocomplete_fields do
    @autocomplete_fields
  end

  def select_fields do
    @select_fields
  end

end
