require Alfred.Helpers, as: H

alias Tino.Test.Helpers.PurchaseOrder, as: Po


defmodule Tino.PurchaseOrderControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.PurchaseOrder


  test "autocomplete purchase_order_test results", %{conn: conn}  do

    setup()

    query = from(po in PurchaseOrder, where: like(po.number, ^("%99993333%")), select: %{"id" => po.id, "number" => po.number, "amount" => po.amount})
    query_res = Repo.all(query)
    H.spit query_res
    res = conn
      |> get(purchase_order_path(conn, :autocomplete, term: "99993333"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(po in PurchaseOrder, where: like(po.number, ^("%9999%")), select: %{"id" => po.id, "number" => po.number, "amount" => po.amount})
    query_res = Repo.all(query)
    res = conn
      |> get(purchase_order_path(conn, :autocomplete, term: "9999"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res


    query = from(po in PurchaseOrder, where: like(po.number, ^("%333%")), select: %{"id" => po.id, "number" => po.number, "amount" => po.amount})
    query_res = Repo.all(query)
    res = conn
      |> get(purchase_order_path(conn, :autocomplete, term: "333"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def setup do
    Po.insert_sample_row(%{"amount" => 3.00134524, "number" => "99993333"})
    Po.insert_sample_row(%{"amount" => 983.4534524352, "number" => "99994333"})
    Po.insert_sample_row(%{"amount" => 9022.45242, "number" => "99995333"})
    Po.insert_sample_row(%{"amount" => 55.524253446225, "number" => "99996333"})
  end
end
