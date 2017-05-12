require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Currency, as: Cu
alias Tino.Test.Helpers.Common

defmodule Tino.CurrencyControllerTest do
    use ExUnit.Case
    use Tino.ConnCase

    alias Tino.Currency

    setup do

      Cu.insert_sample_row(%{"name" => "euro", "code" => "666", "symbol" => "€"})
      Cu.insert_sample_row(%{"name" => "brazillian peso", "code" => "202", "symbol" => "$"})
      Cu.insert_sample_row(%{"name" => "dolar", "code" => "205", "symbol" => "$"})

    end

    test "autocomplete currency results", %{conn: conn}  do

      autocomplete_action("euro", conn)
      autocomplete_action("eu", conn)
      autocomplete_action("ro", conn)

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
        |> get(currency_path(conn, :autocomplete))
        |> response(200)
        |> Poison.decode!
      assert res["valid"] == false
      assert res["result"] == "Param 'term' is required"
    end


    def autocomplete_action(term, conn) do

      fields = ~w(name code)a
      select_fields = ~w(id name code symbol)a

      query_res = Common.build_results(fields, Currency, term, select_fields)
        |> H.Map.stringify_keys

      res = conn
        |> get(currency_path(conn, :autocomplete, term: term))
        |> response(200)
        |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
end
