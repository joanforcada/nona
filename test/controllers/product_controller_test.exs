require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Product, as: Pr

defmodule Tino.ProductControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Product

  setup do
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Video Seeding"})
    Pr.insert_sample_row(%{"code" => "VS2", "name" => "Video Seeding 2"})
    Pr.insert_sample_row(%{"code" => "Nv", "name" => "Native Video"})
    Pr.insert_sample_row(%{"code" => "Pr_N", "name" => "Programmatic Native Video"})
  end

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

    autocomplete_action("", conn)
    res = conn
      |> get(product_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  def autocomplete_action(term, conn) do

    fields = [name: "name", code: "code", product_format: "product_format"]
    select_fields = ~w(id name code)a

    query_res = build_results(fields, term, select_fields)
    res = conn
      |> get(product_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == H.Map.stringify_keys(query_res)
  end

  def build_results(fields, term, select_fields) do
    term = "%#{term}%"
    auto_query =
    Enum.reduce(fields, Product, fn {key, _value}, query ->
      from p in query, or_where: like(field(p, ^key), ^term)
    end)
    |> select([p], map(p, ^select_fields))
    |> H.spit
    res = Repo.all(auto_query)

    case res do
      [] -> "There are no results for this term"
      results -> results
    end
  end


end
