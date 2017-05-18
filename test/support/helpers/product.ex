require Alfred.Helpers, as: H
defmodule Tino.Test.Helpers.Product do
  alias Tino.Product
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
     "name" => "some product",
     "retribution_model" => 2,
     "code" => "sp",
     "product_format" => "some_format",
     "product_status" => 0,
     "invoicing_model" => 1,
     "created_ts" => System.system_time(:nanoseconds),
     "updated_ts" => System.system_time(:nanoseconds)}, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Product.changeset(%Product{}, row)
    Repo.insert(changeset)
    row
  end
end
