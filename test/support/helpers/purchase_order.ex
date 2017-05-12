defmodule Tino.Test.Helpers.PurchaseOrder do
  alias Tino.PurchaseOrder
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
        "number" => "99993333",
        "description" => "some random description",
        "amount" => 5.00149328574827,
        "order_type" => 6,
        "created_ts" => System.system_time(:nanoseconds),
        "updated_ts" => System.system_time(:nanoseconds)}, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = PurchaseOrder.changeset(%PurchaseOrder{}, row)
    Repo.insert(changeset)
    row
  end
end
