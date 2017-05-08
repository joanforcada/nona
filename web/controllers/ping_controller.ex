defmodule Tino.PingController do
  use Tino.Web, :controller

  def ping(conn, params) do text(conn, "Pong") end

end
