require Alfred.Helpers, as: H

alias Tino.Test.Helpers.Offer, as: O
alias Tino.Test.Helpers.Common


defmodule Tino.OfferControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Offer

  setup do
    O.insert_sample_row(%{"permalink" => "88885555", "status" => "pause", "offer_url" => "www.admanmedia.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
    O.insert_sample_row(%{"permalink" => "88885552", "status" => "active", "offer_url" => "www.admanmedia1.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
  end

  test "autocomplete purchase order results", %{conn: conn}  do

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
      |> get(offer_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  def autocomplete_action(term, conn) do

    fields = ~w(permalink name)a
    select_fields = ~w(id permalink name)a

    query_res = Common.build_results(fields, Offer, term, select_fields)
      |> H.Map.stringify_keys

    res = conn
      |> get(offer_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end
end
