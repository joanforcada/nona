require Alfred.Helpers, as: H

alias Tino.Test.Helpers.Offer, as: O


defmodule Tino.OfferControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Offer


  test "autocomplete offer_test results", %{conn: conn}  do

    setup()

    query = from(o in Offer, where: like(o.permalink, ^("%88885555%")), select: %{"id" => o.id, "permalink" => o.permalink, "status" => o.status, "offer_url" => o.offer_url, "preview_url" => o.preview_url, "video_provider" => o.video_provider, "vast_version" => o.vast_version})
    query_res = Repo.all(query)
    H.spit query_res
    res = conn
      |> get(offer_path(conn, :autocomplete, term: "88885555"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(o in Offer, where: like(o.permalink, ^("%8888%")), select: %{"id" => o.id, "permalink" => o.permalink, "status" => o.status, "offer_url" => o.offer_url, "preview_url" => o.preview_url, "video_provider" => o.video_provider, "vast_version" => o.vast_version})
    query_res = Repo.all(query)
    res = conn
      |> get(offer_path(conn, :autocomplete, term: "8888"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res


    query = from(o in Offer, where: like(o.permalink, ^("%555%")), select: %{"id" => o.id, "permalink" => o.permalink, "status" => o.status, "offer_url" => o.offer_url, "preview_url" => o.preview_url, "video_provider" => o.video_provider, "vast_version" => o.vast_version})
    query_res = Repo.all(query)
    res = conn
      |> get(offer_path(conn, :autocomplete, term: "555"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def setup do
    O.insert_sample_row(%{"permalink" => "88885555", "status" => "pause", "offer_url" => "www.admanmedia.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
    O.insert_sample_row(%{"permalink" => "88885552", "status" => "active", "offer_url" => "www.admanmedia1.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
    #Po.insert_sample_row(%{"amount" => Decimal.new(6), "number" => "99994333"})
    #Po.insert_sample_row(%{"amount" => Decimal.new(7), "number" => "99995333"})
    #Po.insert_sample_row(%{"amount" => Decimal.new(8), "number" => "99996333"})
  end


end
