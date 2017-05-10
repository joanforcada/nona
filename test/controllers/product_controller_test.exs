require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Product, as: Pr

defmodule Tino.ProductControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Product

  test "autocomplete video_seeding results", %{conn: conn}  do

    setup()

    autocomplete_action("Video Seeding", conn)
    autocomplete_action("seeding", conn)
    autocomplete_action("video", conn)
    autocomplete_action("vid", conn)
    autocomplete_action("seed", conn)

  end

  test "autocomplete empty result", %{conn: conn}  do

    setup()

    autocomplete_action("some random string", conn)
    autocomplete_action("INtravenoso", conn)
    autocomplete_action("CaMeL", conn)
    autocomplete_action(" ", conn)

  end

  test "autocomplete no term involved", %{conn: conn} do
    setup()

    autocomplete_action("", conn)
    res = conn
      |> get(product_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is missing"
  end

  def autocomplete_action(term, conn) do
    query = from(p in Product, where: like(p.name, ^("%#{term}%")), select: %{"id" => p.id, "name" => p.name, "code" => p.code})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def setup do
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Video Seeding"})
    Pr.insert_sample_row(%{"code" => "VS2", "name" => "Video Seeding 2"})
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Native Video"})
    Pr.insert_sample_row(%{"code" => "Vw", "name" => "Programmatic Native Video"})
  end
end
