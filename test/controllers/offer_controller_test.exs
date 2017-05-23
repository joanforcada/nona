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

    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "cola", "permalink" => "111111111"},
      %{"id" => <some_other_id>, "name" => "cola 2", "permalink" => "22222222"},
      %{"id" => <some_random_id>, "name" => "cola 4", "permalink" => "444444444"} ] }
    """
    test "autocomplete offers results", %{conn: conn}  do

      autocomplete_action("spar", conn)
      autocomplete_action("ol", conn)
      autocomplete_action("ohter", conn)
      autocomplete_action("an", conn)

    end

    @doc """
      Autocomplete with empty results, not existing records for the words searched
      Example URL: campaigns/autocomplete?term=<some_random_term>
      Result: %{"valid" => true, "result" => []}
    """
    test "autocomplete empty result", %{conn: conn}  do

      autocomplete_action("some random string", conn)
      autocomplete_action("TOMIllo", conn)
      autocomplete_action("CaMeL", conn)
      autocomplete_action(" ", conn)

    end


    @doc """
      No param term, should respond accordingly
      Example URL: campaigns/autocomplete
      Result: %{"valid" => false, "result" => "Param 'term' is required" }
    """
    test "autocomplete no term involved", %{conn: conn} do

      autocomplete_action("", conn)
      res = conn
      |> get(offer_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
      assert res["valid"] == false
      assert res["result"] == "Param 'term' is required"
    end

    @doc """
      Dynamic query with provided autocomplete fields, table to look, term of search, and return fields
      Common.build_results(<autocomplete_fields>, model, term, <select_fields>)
      The return value is a JSON with atom keys, pass along to string
      First, directly call the function to get expected result
      Then mock controller action, expect same result
    """
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

      all_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(all_res) == 1

      #Offer with autogenerated permalink, we will not find it if we look for the permalink we mocked
      #Database record increased in 1
      first_res = Common.stringify_element(all_res) |> List.first
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

  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do

      params = %{permalink: "56565656", name: "volcano", status: "trafficking", offer_url: "www.admanmedia2.com"}

      offer_id = offer_query("88885552")
        |> List.first
        |> Map.get(:id)
      update_params = Map.put(params, :id, offer_id)

      put_call(conn, update_params)
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

  defp put_call(conn, params) do
    conn
    |> put(offer_path(conn, :update, struct(Offer, params)), %{offer: params} )
    |> response(200)
    |> Poison.decode!
  end
end
