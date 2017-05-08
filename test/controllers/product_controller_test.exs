require Alfred.Helpers, as: H
defmodule Tino.ProductControllerTest do
  use Tino.ConnCase

  test "autocomplete video_seeding results", %{conn: conn}  do
    conn = get conn, product_path(conn, :autocomplete, term: "Video Seeding")
    res = Poison.decode!(response(conn, 200))
    H.spit Map.get(res, "result")
    assert length(Map.get(res, "result", [])) == 4

    conn = get conn, product_path(conn, :autocomplete, term: "Seeding")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 4

    conn = get conn, product_path(conn, :autocomplete, term: "Video")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 4

    conn = get conn, product_path(conn, :autocomplete, term: "See")
    res = Poison.decode!(response(conn, 200))

    assert length(Map.get(res, "result", [])) == 4
  end

  test "autocomplete empty result", %{conn: conn}  do
    conn = get conn, product_path(conn, :autocomplete, term: "some random string")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: "INtravenoso")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: "CaMeL")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 0

    conn = get conn, product_path(conn, :autocomplete, term: " ")
    res = Poison.decode!(response(conn, 200))
    assert length(Map.get(res, "result", [])) == 0

  end

  test "autocomplete no term involved", %{conn: conn} do
    conn = get conn, product_path(conn, :autocomplete)
    res = Poison.decode!(response(conn, 200))
    assert res == true
  end
end
