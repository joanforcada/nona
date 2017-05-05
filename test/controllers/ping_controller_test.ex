defmodule Tino.PingControllerTest do
  use Tino.ConnCase

  test "GET /ping", %{conn: conn} do
    conn = get conn, "/ping"
    assert html_response(conn, 200) =~ "Pong"
  end
end
