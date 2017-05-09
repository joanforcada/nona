require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Product, as: Pr

defmodule Tino.ProductControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Product

  test "autocomplete video_seeding results", %{conn: conn}  do

    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Video Seeding"})

    query = from(p in Product, where: like(p.name, ^("%Video Seeding%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)

    H.spit query_res
    res = conn
      |> get("/products/autocomplete?term=Video Seeding")
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(p in Product, where: like(p.name, ^("%Video%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "Video"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res


    query = from(p in Product, where: like(p.name, ^("%Seeding%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "Seeding"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(p in Product, where: like(p.name, ^("%seed%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "seed"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(p in Product, where: like(p.name, ^("%vid%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "vid"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

  end

  test "autocomplete empty result", %{conn: conn}  do
    conn = get conn, product_path(conn, :autocomplete, term: "some random string")
    res = Poison.decode!(response(conn, 200))
    # assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: "INtravenoso")
    res = Poison.decode!(response(conn, 200))
    # assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: "CaMeL")
    res = Poison.decode!(response(conn, 200))
    # assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: " ")
    res = Poison.decode!(response(conn, 200))
    # assert length(Map.get(res, "result", [])) == 0

  end

  test "autocomplete no term involved", %{conn: conn} do
    conn = get conn, product_path(conn, :autocomplete)
    res = Poison.decode!(response(conn, 200))
    # assert res == true
  end
end
