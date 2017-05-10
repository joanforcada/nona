require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Campaign, as: C

defmodule Tino.CampaignControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Campaign

  test "autocomplete campaign_cola results", %{conn: conn}  do

    setup()

    query = from(c in Campaign, where: like(c.name, ^("%cola%")), select: %{"id" => c.id, "name" => c.name, "permalink" => c.permalink})
    query_res = Repo.all(query)
    H.spit query_res
    res = conn
      |> get(campaign_path(conn, :autocomplete, term: "cola"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res

    query = from(c in Campaign, where: like(c.name, ^("%co%")), select: %{"id" => c.id, "name" => c.name, "permalink" => c.permalink})
    query_res = Repo.all(query)
    res = conn
      |> get(campaign_path(conn, :autocomplete, term: "co"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res


    query = from(c in Campaign, where: like(c.name, ^("%la%")), select: %{"id" => c.id, "name" => c.name, "permalink" => c.permalink})
    query_res = Repo.all(query)
    res = conn
      |> get(campaign_path(conn, :autocomplete, term: "la"))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def setup do
    C.insert_sample_row(%{"permalink" => "11111111", "name" => "cola"})
    C.insert_sample_row(%{"permalink" => "22222222", "name" => "cola 2"})
    C.insert_sample_row(%{"permalink" => "33333333", "name" => "cola 3"})
    C.insert_sample_row(%{"permalink" => "44444444", "name" => "cola 4"})
  end
end
