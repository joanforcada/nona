defmodule Tino.PingController do
  use Tino.Web, :controller

  def ping(conn, _params) do text(conn, "Pong") end

end
