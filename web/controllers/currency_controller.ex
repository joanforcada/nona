defmodule Tino.CurrencyController do
  use Tino.Web, :controller

  alias Tino.Currency
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name code)a
  @select_fields ~w(id name code symbol)a

  def autocomplete(conn, %{"term" => term}) do
    term = "%#{term}%"

    {:ok, %{model: Currency, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
      |> Common.add_autocomplete_result
      |> build_response

  end

  def autocomplete(conn, _params) do
    json(conn, Map.get(Common.errors, :missing_term))
  end

  def build_response({:ok, %{conn: conn, autocomplete_result: res}}) do
    json(conn, %{valid: true, result: res})
  end
end
