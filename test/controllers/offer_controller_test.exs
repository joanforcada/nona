require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Offer, as: O
alias Tino.Test.Helpers.Common

alias Tino.Repo
import Ecto.Query

defmodule Tino.OfferControllerTest do
  use Tino.ConnCase
  use ExUnit.Case, async: true

  alias Tino.Offer

  setup do
    O.insert_sample_row(%{"permalink" => "88885555", "name" => "spartans", "status" => "pause", "offer_url" => "www.admanmedia.com"})
    O.insert_sample_row(%{"permalink" => "88885552", "name" => "oliva", "status" => "active", "offer_url" => "www.admanmedia1.com"})
    O.insert_sample_row(%{"permalink" => "35224524", "name" => "volcano", "status" => "trafficking", "offer_url" => "www.admanmedia2.com"})
    O.insert_sample_row(%{"permalink" => "56336365", "name" => "some other name", "status" => "reporting", "offer_url" => "www.admanmedia3.com"})
  end

  describe "GET /autocomplete" do
    test "autocomplete offers results", %{conn: conn}  do

      autocomplete_action("spar", conn)
      autocomplete_action("ol", conn)
      autocomplete_action("ohter", conn)
      autocomplete_action("an", conn)

    end

    test "autocomplete empty result", %{conn: conn}  do

      autocomplete_action("some random string", conn)
      autocomplete_action("TOMIllo", conn)
      autocomplete_action("CaMeL", conn)
      autocomplete_action(" ", conn)

    end

    test "autocomplete no term involved", %{conn: conn} do

      autocomplete_action("", conn)
      res = conn
      |> get(offer_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
      assert res["valid"] == false
      assert res["result"] == "Param 'term' is required"
    end

    defp autocomplete_action(term, conn) do

      query_res = Common.build_results(Offer.autocomplete_fields, Offer, term, Offer.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(offer_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end

  describe "POST /create" do
    test "create new valid value", %{conn: conn} do
      params = %{name: "a valid offer", permalink: "12312223"}
      # create_new(conn, params)

      permalink = Map.get(params, :permalink, "")
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4

      O.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name)})

      query_res = offer_query(permalink)
      assert length(query_res) == 1

      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 5

      Repo.delete_all(Offer)

      res = post_call(conn, params)
      assert Map.get(res, "valid")

      #Offer with autogenerated permalink, we will not find it if we look for the permalink we mocked
      query_res = Map.get(res, "result")
        |> Map.get("permalink")
        |> offer_query
      assert length(query_res) == 1

      #Database record increased in 1
      all_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(all_res) == 1

      first_res = Common.stringify_element(query_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      # Invalid value retribution model
      params = %{name: "a valid offer", permalink: "435234235", vast_version: "some random senseless"}
      # create_new(conn, params)

      permalink = Map.get(params, :permalink, "")
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4
      query_res = offer_query(permalink)
      assert length(query_res) == 0

      O.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name), "vast_version" => Map.get(params, :vast_version)})

      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4
      query_res = offer_query(permalink)
      assert length(query_res) == 0

      Repo.delete_all(Offer)

      res = post_call(conn, params)
      refute Map.get(res, "valid")

      query_res = offer_query(permalink)
      assert length(query_res) == 0
    end
  end

  defp offer_query(permalink) do
    query = from o in Offer, where: o.permalink == ^permalink, select: map(o, ^Offer.select_fields)
    Repo.all(query)
  end

  defp post_call(conn, params) do
    conn
    |> post(offer_path(conn, :create, %{"offer" => params}))
    |> response(200)
    |> Poison.decode!
  end

  describe "PUT /update" do
      test "update value", %{conn: conn} do
        update_value("term", conn)
      end

      defp update_value(term, conn) do

      end
    end

end
