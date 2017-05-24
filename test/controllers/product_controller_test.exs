require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Product, as: Pr
alias Tino.Test.Helpers.Common
alias Tino.Repo
import Ecto.Query

defmodule Tino.ProductControllerTest do
  use ExUnit.Case
  use Tino.ConnCase, async: true


  alias Tino.Product

  setup do
    # Populate the database with some fake data
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Video Seeding"})
    Pr.insert_sample_row(%{"code" => "VS2", "name" => "Video Seeding 2"})
    Pr.insert_sample_row(%{"code" => "Nv", "name" => "Native Video"})
    Pr.insert_sample_row(%{"code" => "Pr_N", "name" => "Programmatic Native Video"})
  end

  # Example URL: products/autocomplete?term=Video Seeding
  describe "GET /autocomplete" do

    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "Video Seeding", "code" => "Vw"},
      %{"id" => <some_other_id>, "name" => "Video Seeding 2 2", "code" => "VS2"}]}
    """
    test "autocomplete video_seeding results", %{conn: conn}  do

      autocomplete_action("Video Seeding", conn)
      autocomplete_action("seeding", conn)
      autocomplete_action("video", conn)
      autocomplete_action("vid", conn)
      autocomplete_action("seed", conn)

    end

    @doc """
      Autocomplete with empty results, not existing records for the words searched
      Example URL: products/autocomplete?term=<some_random_term>
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
    Example URL: products/autocomplete
    Result: %{"valid" => false, "result" => "Param 'term' is required" }
    """
    test "autocomplete no term involved", %{conn: conn} do

      autocomplete_action("", conn)
      res = conn
      |> get(product_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
      assert res["valid"] == false
      assert res["result"] == "Param 'term' is required"
    end


    defp autocomplete_action(term, conn) do

      query_res = Common.build_results(Product.autocomplete_fields, Product, term, Product.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(product_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end

  # Create a new value with the params provided via POST call
  describe "POST /create" do
    # Valid params for the creation of a new value
    # URL: POST: products/ body: <params>
    test "create new valid value", %{conn: conn} do
      # A valid params for a valid record
      params = %{name: "a valid product", code: "sc"}

      # get the code for multiuse purposes
      code = Map.get(params, :code, "")
      # Check that the query has all the setup values (4 in this case)
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4

      # Try to insert another value
      Pr.insert_sample_row(%{"code" => code, "name" => Map.get(params, :name)})

      # Check that the value has been inserted
      query_res = product_query(code, Product.select_fields)
      assert length(query_res) == 1

      # And the database record was increased by 1
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 5

      # Delete and perform the insert through the controller
      Repo.delete_all(Product)
      #Mock the controller action
      res = post_call(conn, params)
      # Check the insert performed successfully
      assert Map.get(res, "valid")

      # The only value in the database should be the one inserted by the controller
      all_res = Common.get_all_results(Product, Product.select_fields)
      assert length(all_res) == 1
      # Check the result is the same
      first_res = Common.stringify_element(all_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      # Params with timestamp invalid
      params = %{name: "a valid product", code: "sc", retribution_model: "some retribution"}

      # Fetch the code for later purposes
      code = Map.get(params, :code, "")
      # Check that only the setup values are in DB
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4
      # None with the code provided via params
      query_res = product_query(code, Product.select_fields)
      assert length(query_res) == 0

      # Insert row with the params
      Pr.insert_sample_row(%{"code" => code, "name" => Map.get(params, :name), "retribution_model" => Map.get(params, :retribution_model)})

      # Check that new row did not create
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4
      query_res = product_query(code, Product.select_fields)
      assert length(query_res) == 0


      # Wipe products
      Repo.delete_all(Product)

      # Mock controller call, check return is a controlled error response
      res = post_call(conn, params)
      refute Map.get(res, "valid")

      # Expect same result
      query_res = product_query(code)
      assert length(query_res) == 0
    end
  end

  # Controller call for create
  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do

      params = %{name: "some name for a change"}
      product = product_query("Vw") |> List.first
      changeset = Product.changeset(product, params)

      res = Repo.update(changeset)
      # Update successfully
      assert elem(res, 0) == :ok
      assert elem(res, 1) |> Map.get(:name) == Map.get(params, :name)

      update_params = %{name: "The ultimate Product"} |> Map.put(:id, Map.get(product, :id))

      res = put_call(conn, update_params)
      assert Map.get(res, "valid")
      assert Map.get(res, "result") |> Map.get("name") == Map.get(update_params, :name)
    end

    test "update with invalid params", %{conn: conn} do

      params = %{name: "some name for a change", created_ts: "asd56565d"}
      product = product_query("Vw") |> List.first
      changeset = Product.changeset(product, params)
      refute changeset.valid?

      res = Repo.update(changeset)
      # Not updated, returned error instead
      assert elem(res, 0) == :error
      refute elem(res, 1).valid?
      refute elem(res, 1).errors |> Enum.empty?

      update_params = %{name: "The ultimate Product", created_ts: "asdaasdsad"} |> Map.put(:id, Map.get(product, :id))

      # Put call with status expected (422 -> unprocessable_entity, URL and params are good, but the request contains invalid params)
      res = put_call(conn, update_params, :unprocessable_entity)

      refute Map.get(res, "valid")
    end
  end

  defp product_query(code, select_fields) do
    query = from p in Product, where: p.code == ^code, select: map(p, ^select_fields)
    Repo.all(query)
  end

  defp product_query(code) do
    query = from p in Product, where: p.code == ^code
    Repo.all(query)
  end

  defp post_call(conn, params) do
    conn
    |> post(product_path(conn, :create, %{"product" => params}))
    |> response(200)
    |> Poison.decode!
  end

  defp put_call(conn, params) do
    conn
    |> put(product_path(conn, :update, struct(Product, params)), %{product: params} )
    |> response(200)
    |> Poison.decode!
  end

  def put_call(conn, params, status) do
    conn
    |> put(product_path(conn, :update, struct(Product, params)), %{product: params} )
    |> response(status)
    |> Poison.decode!
  end
end
