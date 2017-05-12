require Alfred.Helpers, as: H

alias Tino.Test.Helpers.PurchaseOrder, as: Po
alias Tino.Test.Helpers.Common


defmodule Tino.PurchaseOrderControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.PurchaseOrder

  setup do
    Po.insert_sample_row(%{"amount" => 3.00134524, "number" => "99993333"})
    Po.insert_sample_row(%{"amount" => 983.4534524352, "number" => "99994333"})
    Po.insert_sample_row(%{"amount" => 9022.45242, "number" => "99995333"})
    Po.insert_sample_row(%{"amount" => 55.524253446225, "number" => "99996333"})
  end

  test "autocomplete purchase order results", %{conn: conn}  do

    autocomplete_action("Video Seeding", conn)
    autocomplete_action("seeding", conn)
    autocomplete_action("video", conn)
    autocomplete_action("vid", conn)
    autocomplete_action("seed", conn)

  end

  test "autocomplete empty result", %{conn: conn}  do

    autocomplete_action("some random string", conn)
    autocomplete_action("INtravenoso", conn)
    autocomplete_action("CaMeL", conn)
    autocomplete_action(" ", conn)

  end

  test "autocomplete no term involved", %{conn: conn} do

    autocomplete_action("", conn)
    res = conn
      |> get(purchase_order_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  def autocomplete_action(term, conn) do

    fields = ~w(description permalink number)a
    select_fields = ~w(id description number)a

    query_res = Common.build_results(fields, PurchaseOrder, term, select_fields)
      |> H.Map.stringify_keys

    res = conn
      |> get(purchase_order_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end


end
