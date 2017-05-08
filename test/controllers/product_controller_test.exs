require Alfred.Helpers, as: H
defmodule Tino.ProductControllerTest do
  use Tino.ConnCase

  test "autocomplete products with video_seeding", %{conn: conn}  do
    conn = get conn, product_path(conn, :autocomplete, term: "Video Seeding")

    res = Poison.decode!(response(conn, 200))
    assert List.size
  end
end
