defmodule Tino.Test.Helpers.PurchaseOrder do
  alias Tino.PurchaseOrder
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
        "number" => "99999999",
        "amount" => "5,5",
        "order_type" => "60",
        "created_ts" => System.system_time(:nanoseconds),
        "updated_ts" => System.system_time(:nanoseconds)
    }, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = PurchaseOrder.changeset(%PurchaseOrder{}, row)
    res = Repo.insert(changeset)
  end
end
