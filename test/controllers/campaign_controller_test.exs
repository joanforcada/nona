require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Campaign, as: C

defmodule Tino.CampaignControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Campaign

  setup do
    C.insert_sample_row(%{"permalink" => "11111111", "name" => "cola"})
    C.insert_sample_row(%{"permalink" => "22222222", "name" => "cola 2"})
    C.insert_sample_row(%{"permalink" => "33333333", "name" => "campaign 3"})
    C.insert_sample_row(%{"permalink" => "44444444", "name" => "cola 4"})
  end

  test "autocomplete campaign_cola results", %{conn: conn}  do

    autocomplete_action("cola", conn)
    autocomplete_action("co", conn)
    autocomplete_action("la", conn)
  end

  def autocomplete_action(term, conn) do
    # term = "%#{term}%"
    fields = [name: "name", permalink: "permalink"]


    query_res = build_results(fields, term)
    res = conn
      |> get(product_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def build_results(fields, term) do
    auto_query = Enum.reduce(fields, Campaign, fn {key, _value}, query ->
    from p in query, or_where: like(field(p, ^key), ^term)
    end)
     |> select([c, _], %{"id" => c.id, "name" => c.name, "permalink" => c.permalink})
    case Repo.all(auto_query) do
      [] -> "There are no results for this term"
      results -> results
    end
  end
end
