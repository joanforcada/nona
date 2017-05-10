require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Campaign, as: Pr

defmodule Tino.CampaignControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Campaign

  test "autocomplete campaign_cola results", %{conn: conn}  do

    setup()

    query = from(p in Campaign, where: like(p.name, ^("%cola%")), select: %{"id" => p.id, "name" => p.name, "permalink" => p.permalink})
    query_res = Repo.all(query)
    H.spit query_res
    res = conn
      |> get(campaign_path(conn, :autocomplete, term: "cola"))
      |> response(200)
      |> Poison.depermalink!
    assert Map.get(res, "result", []) == query_res

    query = from(p in Campaign, where: like(p.name, ^("%co%")), select: %{"id" => p.id, "name" => p.name, "permalink" => p.permalink})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "co"))
      |> response(200)
      |> Poison.depermalink!
    assert Map.get(res, "result", []) == query_res


    query = from(p in Campaign, where: like(p.name, ^("%la%")), select: %{"id" => p.id, "name" => p.name, "permalink" => p.permalink})
    query_res = Repo.all(query)
    res = conn
      |> get(product_path(conn, :autocomplete, term: "la"))
      |> response(200)
      |> Poison.depermalink!
    assert Map.get(res, "result", []) == query_res
    
end
