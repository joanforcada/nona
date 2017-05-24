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
    # Populate the database with some fake data
    C.insert_sample_row(%{"permalink" => "11111111", "name" => "cola"})
    C.insert_sample_row(%{"permalink" => "22222222", "name" => "cola 2"})
    C.insert_sample_row(%{"permalink" => "33333333", "name" => "campaign 3"})
    C.insert_sample_row(%{"permalink" => "44444444", "name" => "cola 4"})
  end

  # Example URL: campaigns/autocomplete?term=cola
  describe "GET /autocomplete" do
    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "cola", "permalink" => "111111111"},
      %{"id" => <some_other_id>, "name" => "cola 2", "permalink" => "22222222"},
      %{"id" => <some_random_id>, "name" => "cola 4", "permalink" => "444444444"} ] }
    """
    test "autocomplete campaign cola results", %{conn: conn}  do

      autocomplete_action("cola", conn)
      autocomplete_action("co", conn)
      autocomplete_action("la", conn)
      autocomplete_action("amp", conn)
      autocomplete_action("3", conn)

    end
    @doc """
      Autocomplete with empty results, not existing records for the words searched
      Example URL: campaigns/autocomplete?term=<some_random_term>
      Result: %{"valid" => true, "result" => []}
    """
    test "autocomplete empty result", %{conn: conn}  do

      autocomplete_action("some random string", conn)
      autocomplete_action("INtravenoso", conn)
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

  # Create a new value with the params provided via POST call
  describe "POST /create" do
    # Valid params for the creation of a new value
    # URL: POST: campaigns/ body: <params>
    test "create new valid value", %{conn: conn} do
      # A valid params for a valid record
      params = %{name: "a valid campaign", permalink: "91204393"}

      # get the permalink for multiuse purposes
      permalink = Map.get(params, :permalink, "")
      # Check that the query has all the setup values (4 in this case)
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4

      # Try to insert another value
      C.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name)})

      # Check that the value has been inserted
      query_res = campaign_query(permalink, Campaign.select_fields)
      assert length(query_res) == 1

      # And the database record was increased by 1
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 5

      # Delete and perform the insert through the controller
      Repo.delete_all(Campaign)
      # Mock the controller action
      res = post_call(conn, params)
      # Check the insert performed successfully
      assert Map.get(res, "valid")

      # The only value in the database should be the one inserted by the controller
      all_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(all_res) == 1
      # Check the result is the same
      first_res = Common.stringify_element(all_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      # Params with timestamp invalid
      params = %{name: "a valid campaign", permalink: "91204393", created_ts: "somewhere in time and space...."}

      # Fetch the permalink for later purposes
      permalink = Map.get(params, :permalink, "")
      # Check that only the setup values are in DB
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4
      # None with the permalink provided via params
      query_res = campaign_query(permalink, Campaign.select_fields)
      assert length(query_res) == 0

      # Insert row with the params
      C.insert_sample_row(%{"permalink" => permalink, "name" => Map.get(params, :name), "created_ts" => Map.get(params, :created_ts)})

      # Check that new row did not create
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 4
      query_res = campaign_query(permalink, Campaign.select_fields)
      assert length(query_res) == 0

      # Wipe campaigns
      Repo.delete_all(Campaign)

      # Mock controller call, check return is a controlled error response
      res = post_call(conn, params)
      refute Map.get(res, "valid")

      # Expect same result
      query_res = Common.get_all_results(Campaign, Campaign.select_fields)
      assert length(query_res) == 0
    end
  end

    # Controller call for create
  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do

      params = %{name: "some name for a change"}
      campaign = campaign_query("11111111") |> List.first
      changeset = Campaign.changeset(campaign, params)
      assert changeset.valid?

      res = Repo.update(changeset)
      # Update successfully
      assert elem(res, 0) == :ok
      assert elem(res, 1) |> Map.get(:name) == Map.get(params, :name)

      update_params = %{name: "The ultimate Campaign"} |> Map.put(:id, Map.get(campaign, :id))

      res = put_call(conn, update_params)
      assert Map.get(res, "valid")
      assert Map.get(res, "result") |> Map.get("name") == Map.get(update_params, :name)
    end

    test "update with invalid params", %{conn: conn} do

      params = %{name: "some name for a change", created_ts: "fjeaiojaofjoifj"}
      campaign = campaign_query("11111111") |> List.first
      changeset = Campaign.changeset(campaign, params)
      refute changeset.valid?

      res = Repo.update(changeset)
      # Not updated, returned error instead
      assert elem(res, 0) == :error
      refute elem(res, 1).valid?
      refute elem(res, 1).errors |> Enum.empty?

      update_params = %{name: "A blast",  created_ts: "fjeaiojaofjoifj"} |> Map.put(:id, Map.get(campaign, :id))

      # Put call with status expected (422 -> unprocessable_entity, URL and params are good, but the request contains invalid params)
      res = put_call(conn, update_params, :unprocessable_entity)

      refute Map.get(res, "valid")
    end  
  end


  # Campaign query for a single result
  defp campaign_query(permalink, select_fields) do
    query = from c in Campaign, where: c.permalink == ^permalink, select: map(c, ^select_fields)
    Repo.all(query)
  end

  defp campaign_query(permalink) do
    query = from c in Campaign, where: c.permalink == ^permalink
    Repo.all(query)
  end

  # Mock controller create action
  defp post_call(conn, params) do
    conn
    |> post(campaign_path(conn, :create, %{"campaign" => params}))
    |> response(200)
    |> Poison.decode!
  end

  # Mock controller update action
  def put_call(conn, params) do
    conn
    |> put(campaign_path(conn, :update, struct(Campaign, params)), %{campaign: params} )
    |> response(200)
    |> Poison.decode!
  end

  def put_call(conn, params, status) do
    conn
    |> put(campaign_path(conn, :update, struct(Campaign, params)), %{campaign: params} )
    |> response(status)
    |> Poison.decode!
  end
end
