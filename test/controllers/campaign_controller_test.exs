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
    test "create new valid value", %{conn: conn} do
      # A valid params for a valid record
      params = %{name: "a valid campaign", permalink: "91204393"}

      # get the permalink for multiuse purposes
      permalink = Map.get(params, :permalink)
      # Check that the query has all the setup values (4 in this case)
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4

      # Try to insert another value
      C.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name)})

      # Check that the value has been inserted
      query_res = campaign_query(permalink)
      assert length(query_res) == 1

      # And the database record was increased by 1
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 5

      # Delete and perform the insert through the controller
      Repo.delete_all(Campaign)

      res = controller_call(conn, params)

      query_res = Map.get(res, "result")
        |> Map.get("permalink")
        |> campaign_query

      assert length(query_res) == 1
      first_res = Common.stringify_element(query_res)
        |> List.first
      assert Map.get(res, "result", []) == first_res
    end

    test "create an invalid value", %{conn: conn} do
      params = %{name: "a valid campaign", permalink: "91204393", created_ts: "somewhere in time and space...."}

      permalink = Map.get(params, :permalink, "")
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4

      C.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name), "created_ts" => Map.get(params, :created_ts)})

      query_res = campaign_query(permalink)
      assert length(query_res) == 0

      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4

      Repo.delete_all(Campaign)

      res = controller_call(conn, params)


      query_res = campaign_query(permalink)
      assert length(query_res) == 0
      first_res = Common.stringify_element(query_res)
        |> List.first
      assert Map.get(res, "result", []) == first_res
    end

    # Campaign query for a single result
    defp campaign_query(permalink) do
      query = from c in Campaign, where: c.permalink == ^permalink, select: map(c, ^Campaign.select_fields)
      Repo.all(query)
    end

    # Controller call for create
    defp controller_call(conn, params) do
      conn
      |> post(campaign_path(conn, :create, %{"campaign" => params}))
      |> response(200)
      |> Poison.decode!
    end
  end

  describe "PUT /update" do
    test "update value", %{conn: conn} do

      # update_value(conn)
    end

    defp update_value(conn, id, params) do
    end
  end


end
