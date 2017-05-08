require Alfred.Helpers, as: H
defmodule Tino.ProductControllerTest do
  use Tino.ConnCase

  test "autocomplete products with video_seeding", %{conn: conn}  do
    conn = get conn, product_path(conn, :autocomplete)

    H.spit response(conn, 200)
  end
end
