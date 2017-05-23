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
  @doc """
    Autocomplete with the whole word, or part of it
    Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "cola", "permalink" => "111111111"},
    %{"id" => <some_other_id>, "name" => "cola 2", "permalink" => "22222222"},
    %{"id" => <some_random_id>, "name" => "cola 4", "permalink" => "444444444"} ] }
  """
  test "autocomplete campaign results", %{conn: conn}  do

    autocomplete_action("fran", conn)
    autocomplete_action("ger", conn)
    autocomplete_action("dub", conn)
    autocomplete_action("chil", conn)

  end

  @doc """
    Autocomplete with empty results, not existing records for the words searched
    Example URL: campaigns/autocomplete?term=<some_random_term>
    Result: %{"valid" => true, "result" => []}
  """
  test "autocomplete empty result", %{conn: conn}  do

    autocomplete_action("some random string", conn)
    autocomplete_action("INtravenoso", conn)
    autocomplete_action("CaMeL", conn)
    autocomplete_action(" ", conn)

  end

  @doc """
    No param term, should respond accordingly
    Example URL: campaigns/autocomplete
    Result: %{"valid" => false, "result" => "Param 'term' is required" }
  """
  test "autocomplete no term involved", %{conn: conn} do

    autocomplete_action("", conn)
    res = conn
      |> get(country_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
    assert res["valid"] == false
    assert res["result"] == "Param 'term' is required"
  end

  @doc """
    Dynamic query with provided autocomplete fields, table to look, term of search, and return fields
    Common.build_results(<autocomplete_fields>, model, term, <select_fields>)
    The return value is a JSON with atom keys, pass along to string
    First, directly call the function to get expected result
    Then mock controller action, expect same result
  """
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
