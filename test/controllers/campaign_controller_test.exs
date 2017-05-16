require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Campaign, as: C
alias Tino.Test.Helpers.Common

alias Tino.Repo
import Ecto.Query

defmodule Tino.CampaignControllerTest do
  use ExUnit.Case
  use Tino.ConnCase



  alias Tino.Campaign

  setup do
    C.insert_sample_row(%{"permalink" => "11111111", "name" => "cola"})
    C.insert_sample_row(%{"permalink" => "22222222", "name" => "cola 2"})
    C.insert_sample_row(%{"permalink" => "33333333", "name" => "campaign 3"})
    C.insert_sample_row(%{"permalink" => "44444444", "name" => "cola 4"})
  end

  test "autocomplete campaign cola results", %{conn: conn}  do

    autocomplete_action("cola", conn)
    autocomplete_action("co", conn)
    autocomplete_action("la", conn)
    autocomplete_action("amp", conn)
    autocomplete_action("3", conn)


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
      |> get(campaign_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  test "create new value", %{conn: conn} do
    create_new_action("term", conn)
  end


  test "update value", %{conn: conn} do
    update_value("term", conn)
  end

  defp update_value(term, conn) do

  end

  defp autocomplete_action(term, conn) do

    fields = ~w(permalink name)a
    select_fields = ~w(id permalink name)a

    query_res = Common.build_results(fields, Campaign, term, select_fields)
    |> H.Map.stringify_keys

    res = conn
      |> get(campaign_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  defp create_new_action(term, conn) do

    create_value = (C.insert_sample_row(%{"permalink" => "00000000", "name" => "cola 00"}))
    query = from c in Campaign, where: c.permalink == "00000000", select: %{name: c.name, permalink: c.permalink}

    query_res = Repo.all(query)

    H.spit(query_res)

    #res = conn
    #  |> post(campaign_path(conn, :create, term: term))
    #  |> response(200)
    #  |> Poison.decode!

    #assert Map.get(res, "result", []) == query_res

  end


end
