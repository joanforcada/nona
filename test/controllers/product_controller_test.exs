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

<<<<<<< HEAD

  describe "GET /autocomplete" do
    test "autocomplete video_seeding results", %{conn: conn}  do

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

=======
  describe "GET /autocomplete" do
    test "autocomplete video_seeding results", %{conn: conn}  do

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

>>>>>>> 2031b1ee6e311465dd9ae077c206d139e39051d5
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

      res = controller_call(conn, params)

      query_res = product_query(code)
      assert length(query_res) == 1
      first_res = format_product(query_res)
      assert Map.get(res, "result", []) == first_res
    end

    test "create an invalid value", %{conn: conn} do
      params = %{name: "a valid product", code: "sc", retribution_model: "some retribution"}
      # create_new(conn, params)

      code = Map.get(params, :code, "")
      query_res = product_query(code)
      assert length(query_res) == 0

      Pr.insert_sample_row(%{"code" => code, "name" => Map.get(params, :name)})

      query_res = product_query(code)
      assert length(query_res) == 1

      Repo.delete_all(Product)

      res = controller_call(conn, params)

      query_res = product_query(code)
      assert length(query_res) == 1
      first_res = format_product(query_res)
      assert Map.get(res, "result", []) == first_res
    end
  end

  defp product_query(code) do
    query = from p in Product, where: p.code == ^code, select: map(p, ^Product.select_fields)
    Repo.all(query)
  end

  defp controller_call(conn, params) do
    conn
    |> post(campaign_path(conn, :create, %{"product" => params}))
    |> response(200)
    |> Poison.decode!
  end





=======
  end

  describe "POST /create" do
    test "create new value", %{conn: conn} do
      create_new_action(conn)
    end
  end

  defp create_new_action(conn) do

    query = from pr in Product, where: pr.name == "intext", select: map(pr, ^Product.select_fields)
    query_res = Repo.all(query)
    assert length(query_res) == 0

    Pr.insert_sample_row(%{"name" => "intext", "code" => "I"})

    query_res = Repo.all(query)

    assert length(query_res) == 1

    Repo.delete_all(Product)

    res = conn
     |> post(product_path(conn, :create, %{"product" => %{name: "intext", code: "I"}}))
     |> response(200)
     |> Poison.decode!

     query = from pr in Product, select: map(pr, ^Product.select_fields)
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

  describe "PUT /update" do
      test "update value", %{conn: conn} do
        update_value("term", conn)
      end

      defp update_value(term, conn) do

      end
    end

>>>>>>> 2031b1ee6e311465dd9ae077c206d139e39051d5
end
