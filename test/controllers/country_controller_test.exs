require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Country, as: Co

defmodule Tino.CountryControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Country

  setup do

    Co.insert_sample_row(%{"name" => "france", "iso_code" => "44444444"})
    Co.insert_sample_row(%{"name" => "germany", "iso_code" => "45454545"})
    Co.insert_sample_row(%{"name" => "germany", "iso_code" => "99994545"})
    Co.insert_sample_row(%{"name" => "Chile", "iso_code" => "33333333"})

  end

  test "autocomplete country results", %{conn: conn}  do

    autocomplete_action("germany", conn)
    autocomplete_action("ger", conn)
    autocomplete_action("many", conn)

  end

  test "autocomplete empty result", %{conn: conn}  do

    autocomplete_action("some random strin", conn)
    autocomplete_action("INtravenoso", conn)
    autocomplete_action("CaMeL", conn)
    autocomplete_action(" ", conn)

  end

  test "autocomplete no term involved", %{conn: conn} do

    autocomplete_action("", conn)
    res = conn
      |> get(country_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end


  def autocomplete_action(term, conn) do
    # term = "%#{term}%"
    fields = [name: "name", iso_code: "iso_code"]
    select_fields = ~w(id name iso_code)a


    query_res = build_results(fields, term, select_fields)
      |> H.Map.stringify_keys

    res = conn
      |> get(country_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end

  def build_results(fields, term, select_fields) do
    term = "%#{term}%"
    auto_query =
    Enum.reduce(fields, Country, fn {key, _value}, query ->
      from co in query, or_where: like(field(co, ^key), ^term)
    end)
    #H.spit auto_query
    |> select([p], map(p, ^select_fields))
    res = Repo.all(auto_query)
    #H.spit res

    case res do
      [] -> "There are no results for this term"
      results -> results
    end
  end
end
