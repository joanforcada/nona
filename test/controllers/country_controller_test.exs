require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Country, as: Co
alias Tino.Test.Helpers.Common

defmodule Tino.CountryControllerTest do
  use ExUnit.Case
  use Tino.ConnCase

  alias Tino.Country

  setup do

    Co.insert_sample_row(%{"name" => "france", "iso_code" => "44444444"})
    Co.insert_sample_row(%{"name" => "germany", "iso_code" => "45454545"})
    Co.insert_sample_row(%{"name" => "dublin", "iso_code" => "99994545"})
    Co.insert_sample_row(%{"name" => "Chile", "iso_code" => "33333333"})

  end

  test "autocomplete campaign results", %{conn: conn}  do

    autocomplete_action("fran", conn)
    autocomplete_action("ger", conn)
    autocomplete_action("dub", conn)
    autocomplete_action("chil", conn)

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
      |> get(country_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  def autocomplete_action(term, conn) do

    fields = ~w(name iso_code)a
    select_fields = ~w(id name iso_code)a

    query_res = Common.build_results(fields, Country, term, select_fields)
      |> H.Map.stringify_keys

    res = conn
      |> get(country_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
    assert Map.get(res, "result", []) == query_res
  end
end
