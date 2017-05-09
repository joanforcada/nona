defmodule Tino.Test.Helpers.Product do
  alias Tino.Product
  alias Tino.Repo
  def get_sample_row(data) do
    data = Map.merge(%{
     "name" => "some product",
     "retribution_model" => 2,
     "code" => "sp",
     "product_format" => "some_format",
     "product_status" => 0,
     "invoicing_model" => 1,
     "created_ts" => DateTime.utc_now
   }, data)

  end

  # schema "products" do
    # field :name, :string
    # field :retribution_model, :integer
    # field :code, :string
    # field :product_format, :string
    # field :product_status, :integer
    # field :invoicing_model, :integer

    # has_many :offers, Tino.Offer

    # timestamps()
  # end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Product.changeset(%Product{}, row)
    res = Repo.insert(changeset)
    IO.inspect res
  end
end
