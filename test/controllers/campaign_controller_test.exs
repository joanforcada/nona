require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Campaign, as: C
alias Tino.Test.Helpers.Common

alias Tino.Repo
import Ecto.Query

defmodule Tino.CampaignControllerTest do
  use Tino.ConnCase
  use ExUnit.Case, async: true



  alias Tino.Campaign

  setup do
    C.insert_sample_row(%{"permalink" => "11111111", "name" => "cola"})
    C.insert_sample_row(%{"permalink" => "22222222", "name" => "cola 2"})
    C.insert_sample_row(%{"permalink" => "33333333", "name" => "campaign 3"})
    C.insert_sample_row(%{"permalink" => "44444444", "name" => "cola 4"})
  end

  describe "GET /autocomplete" do
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

    defp autocomplete_action(term, conn) do

      query_res = Common.build_results(Campaign.autocomplete_fields, Campaign, term, Campaign.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(campaign_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end

  describe "POST /create" do
    test "create new value", %{conn: conn} do
      create_new_action(conn)
    end


    defp create_new_action(conn) do

      query = from c in Campaign, where: c.permalink == "00000000", select: map(c, ^Campaign.select_fields)
      query_res = Repo.all(query)
      assert length(query_res) == 0

      create_value = (C.insert_sample_row(%{"permalink" => "00000000", "name" => "cola 00"}))

      query_res = Repo.all(query)
      assert length(query_res) == 1

      Repo.delete_all(Campaign)

      res = conn
       |> post(campaign_path(conn, :create, %{"campaign" => %{name: "cola 00"}}))
       |> response(200)
       |> Poison.decode!

      query = from c in Campaign, select: map(c, ^Campaign.select_fields)
      query_res = Repo.all(query)
      assert length(query_res) == 1
      first_res = query_res
        |> H.spit
        |> H.Map.stringify_keys
        |> H.spit
        |> List.first
        |> H.spit
      assert Map.get(res, "result", []) == first_res

    end
  end

  describe "PUT /update" do
    test "update value", %{conn: conn} do
      update_value("term", conn)
    end

    defp update_value(term, conn) do

    end
  end


end
