require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Offer, as: O
alias Tino.Test.Helpers.Common

alias Tino.Repo
import Ecto.Query

defmodule Tino.OfferControllerTest do
  use Tino.ConnCase
  use ExUnit.Case, async: true

  alias Tino.Offer

  setup do
    O.insert_sample_row(%{"permalink" => "88885555", "status" => "pause", "offer_url" => "www.admanmedia.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
    O.insert_sample_row(%{"permalink" => "88885552", "status" => "active", "offer_url" => "www.admanmedia1.com", "preview_url" => "www.admanmedia.com", "video_provider" => "5", "vast_version" => "3"})
  end

  describe "GET /autocomplete" do
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

    defp autocomplete_action(term, conn) do

      #fields = ~w(permalink name)a
      #select_fields = ~w(id permalink name)a

      query_res = Common.build_results(Offer.autocomplete_fields, Offer, term, Offer.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(offer_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end

  describe "POST /create" do
    test "create new value", %{conn: conn} do
      create_new_action(conn)
    end
  end

  defp create_new_action(conn) do

    query = from o in Offer, where: o.permalink == "00000001", select: map(o, ^Offer.select_fields)
    query_res = Repo.all(query)
    assert length(query_res) == 0

    O.insert_sample_row(%{"permalink" => "00000001", "name" => "cola 99"})

    query_res = Repo.all(query)
    H.spit(query_res)
    assert length(query_res) == 1

    Repo.delete_all(Offer)

  #  query_all = from o in Offer, select: map(o, ^Offer.select_fields)
  #  query_res = Repo.all(query_res)


    res = conn
      |> post(offer_path(conn, :create, %{"offer" => %{name: "cola 00"}}))
      |> response(200)
      |> Poison.decode!

      query = from o in Offer, select: map(o, ^Offer.select_fields)
      query_res = Repo.all(query)
      assert length(query_res) == 1
      first_res = query_res
        |> H.spit
        |> H.Map.stringify_keys
        |> H.spit
        |> List.first
        |> H.spit
      assert Map.get(res, "result", []) == first_res

      #Repo.delete_all(Offer)


  end

  describe "PUT /update" do
      test "update value", %{conn: conn} do
        update_value("term", conn)
      end

      defp update_value(term, conn) do

      end
    end

end
