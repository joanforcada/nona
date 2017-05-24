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

  # Example URL: offers/autocomplete?term="?"
  describe "GET /autocomplete" do

    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "spartans", "permalink" => "88885555"},
      %{"id" => <some_other_id>, "name" => "oliva", "permalink" => "88885552"},
      %{"id" => <some_random_id}, "name" => "volcano", "permalink" => "35224524"},
      %{"id" => <some_random_id>, "name" => "some other name", "permalink" => "56336365"} ] }
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
      Example URL: offers/autocomplete
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

  # Create a new value with the params provided via POST call
  describe "POST /create" do
    # Valid params for the creation of a new value
    # URL: POST: offers/ body: <params>
    test "create new valid value", %{conn: conn} do
      # A valid params for a valid record
      params = %{name: "a valid offer", permalink: "12312223"}

      # get the permalink for multiuse purposes
      permalink = Map.get(params, :permalink, "")
      # Check that the query has all the setup values (4 in this case)
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4

      # Try to insert another value
      O.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name)})

      # Checj that the value has been inserted
      query_res = offer_query(permalink, Offer.select_fields)
      assert length(query_res) == 1

      # And the database record was increased by 1
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 5

      # Delete and perform the insert through the controller
      Repo.delete_all(Offer)
      # Mock the controller action
      res = post_call(conn, params)
      # Chech the insert performed successfully
      assert Map.get(res, "valid")

      # The only value in the database should be the one inserted by the controller
      all_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(all_res) == 1
      # Check the result is the same
      first_res = Common.stringify_element(all_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      # Params with timestamp invalid
      params = %{name: "a valid offer", permalink: "435234235", vast_version: "some random senseless"}

      # Fetch the permalink for later purposes
      permalink = Map.get(params, :permalink, "")
      # Check that only the setup values are in DB
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4
      # None with the permalink provided via params
      query_res = offer_query(permalink, Offer.select_fields)
      assert length(query_res) == 0

      # Insert row with the params
      O.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name), "vast_version" => Map.get(params, :vast_version)})

      # Check that new row did not create
      query_res = Common.get_all_results(Offer, Offer.select_fields)
      assert length(query_res) == 4
      query_res = offer_query(permalink, Offer.select_fields)
      assert length(query_res) == 0

      # Wipe offers
      Repo.delete_all(Offer)

      # Mock controller call, check return is a controlled error response
      res = post_call(conn, params)
      refute Map.get(res, "valid")

      # Expect same result
      query_res = offer_query(permalink, Offer.select_fields)
      assert length(query_res) == 0
    end
  end

  # controller call for create
  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do

      params = %{name: "some name for a change"}
      offer = offer_query("88885552") |> List.first
      changeset = Offer.changeset(offer, params)

      res = Repo.update(changeset)
      # Update successfully
      assert elem(res, 0) == :ok
      assert elem(res, 1) |> Map.get(:name) == Map.get(params, :name)

      update_params = %{name: "The ultimate offer"} |> Map.put(:id, Map.get(offer, :id))

      res = put_call(conn, update_params)
      assert Map.get(res, "valid")
      assert Map.get(res, "result") |> Map.get("name") == Map.get(update_params, :name)
    end

    test "update with invalid params", %{conn: conn} do

      params = %{name: "some name for a change", created_ts: "a16asda5sdas"}
      offer = offer_query("88885552") |> List.first
      changeset = Offer.changeset(offer, params)
      refute changeset.valid?

      res = Repo.update(changeset)
      # Not updated, returned error instead
      assert elem(res, 0) == :error
      refute elem(res, 1).valid?
      refute elem(res, 1).errors |> Enum.empty?

      update_params = %{name: "The ultimate Offer", created_ts: "asd548sd54"} |> Map.put(:id, Map.get(offer, :id))

      # Put call with status expected (422) -> unprocessable_entity, URL and params are good, but the request contains invalid params)
      res = put_call(conn, update_params, :unprocessable_entity)

      refute Map.get(res, "valid")
    end
  end

  # Offer query for a single result
  defp offer_query(permalink, select_fields) do
    query = from o in Offer, where: o.permalink == ^permalink, select: map(o, ^select_fields)
    Repo.all(query)
  end

  defp offer_query(permalink) do
    query = from o in Offer, where: o.permalink == ^permalink
    Repo.all(query)
  end

  # Mock controller create action
  defp post_call(conn, params) do
    conn
    |> post(offer_path(conn, :create, %{"offer" => params}))
    |> response(200)
    |> Poison.decode!
  end

  # Mock controller update action
  defp put_call(conn, params) do
    conn
    |> put(offer_path(conn, :update, struct(Offer, params)), %{offer: params} )
    |> response(200)
    |> Poison.decode!
  end

  defp put_call(conn, params, status) do
    conn
    |> put(offer_path(conn, :update, struct(Offer, params)), %{offer: params} )
    |> response(status)
    |> Poison.decode!
  end
end
