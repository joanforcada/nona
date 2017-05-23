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
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Video Seeding"})
    Pr.insert_sample_row(%{"code" => "VS2", "name" => "Video Seeding 2"})
    Pr.insert_sample_row(%{"code" => "Nv", "name" => "Native Video"})
    Pr.insert_sample_row(%{"code" => "Pr_N", "name" => "Programmatic Native Video"})
  end

  describe "GET /autocomplete" do

    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "cola", "permalink" => "111111111"},
      %{"id" => <some_other_id>, "name" => "cola 2", "permalink" => "22222222"},
      %{"id" => <some_random_id>, "name" => "cola 4", "permalink" => "444444444"} ] }
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
      |> get(product_path(conn, :autocomplete))
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

      query_res = Common.build_results(Product.autocomplete_fields, Product, term, Product.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(product_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end

  describe "POST /create" do
    test "create new valid value", %{conn: conn} do
      params = %{name: "a valid product", code: "sc"}
      # create_new(conn, params)

      code = Map.get(params, :code, "")
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4

      Pr.insert_sample_row(%{"code" => code, "name" => Map.get(params, :name)})

      query_res = product_query(code)
      assert length(query_res) == 1

      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 5

      Repo.delete_all(Product)

      res = post_call(conn, params)
      assert Map.get(res, "valid")

      all_res = Common.get_all_results(Product, Product.select_fields)
      assert length(all_res) == 1

      #H.spit all_res

      query_res = product_query(code)
      #H.spit query_res
      assert length(query_res) == 1
      first_res = Common.stringify_element(query_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      # Invalid value retribution model
      params = %{name: "a valid product", code: "sc", retribution_model: "some retribution"}
      # create_new(conn, params)

      code = Map.get(params, :code, "")
      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4
      query_res = product_query(code)
      assert length(query_res) == 0

      Pr.insert_sample_row(%{"code" => code, "name" => Map.get(params, :name), "retribution_model" => Map.get(params, :retribution_model)})

      query_res = Common.get_all_results(Product, Product.select_fields)
      assert length(query_res) == 4
      query_res = product_query(code)
      assert length(query_res) == 0


      Repo.delete_all(Product)

      res = post_call(conn, params)
      refute Map.get(res, "valid")

      query_res = product_query(code)
      assert length(query_res) == 0
    end
  end

  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do
      # Update "Programmatic Native Video"
      # update params (Mssing ID to update it)
      params = %{name: "some name for a change", code: "snfac", product_format: "some other format"}
      # Find Product ID
      #H.spit params

      product_id = product_query("Pr_N")
        |> List.first
        |> Map.get(:id)
      update_params = Map.put(params, :id, product_id)

      #H.spit update_params

      # Put product ID inside params
      # update_params = %{ id: product_id, params: params }
      # conn
      # |> put(product_path(conn, :update, update_params))
      # |> response(200)
      # |> Poison.decode!

      put_call(conn, update_params)
    end
  end

  defp product_query(code) do
    query = from p in Product, where: p.code == ^code, select: map(p, ^Product.select_fields)
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
end
