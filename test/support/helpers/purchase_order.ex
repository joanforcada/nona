defmodule Tino.Test.Helpers.PurchaseOrder do
  alias Tino.PurchaseOrder
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
        "number" => "99993333",
        "amount" => "5.001",
        "order_type" => 6,
        "created_ts" => System.system_time(:nanoseconds),
        "updated_ts" => System.system_time(:nanoseconds)}, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = PurchaseOrder.changeset(%PurchaseOrder{}, row)
    res = Repo.insert(changeset)
    IO.inspect(res)
  end
end
