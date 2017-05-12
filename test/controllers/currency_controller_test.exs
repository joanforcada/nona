require Alfred.Helpers, as: H
alias Tino.Test.Helpers.Currency, as: Cu

defmodule Tino.CurrencyControllerTest do
    use ExUnit.Case
    use Tino.ConnCase

    alias Tino.Currency

    setup do

      Cu.insert_sample_row(%{"name" => "euro", "code" => "666", "symbol" => "€"})
      Cu.insert_sample_row(%{"name" => "euro", "code" => "202", "symbol" => "€"})
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
        # term = "%#{term}%"
      fields = [name: "name", code: "code", symbol: "symbol"]
      select_fields = ~w(id name code)a


      query_res = build_results(fields, term, select_fields)
        |> H.Map.stringify_keys

      res = conn
        |> get(currency_path(conn, :autocomplete, term: term))
        |> response(200)
        |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end

    def build_results(fields, term, select_fields) do
      term = "%#{term}%"
      auto_query =
      Enum.reduce(fields, Currency, fn {key, _value}, query ->
        from cu in query, or_where: like(field(cu, ^key), ^term)
      end)
      #H.spit auto_query
      |> select([cu], map(cu, ^select_fields))
      res = Repo.all(auto_query)
      #H.spit res

      case res do
        [] -> "There are no results for this term"
        results -> results
      end
    end
end
