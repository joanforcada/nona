defmodule Tino.CountryController do
  use Tino.Web, :controller

  alias Tino.Country
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name iso_code)a
  @select_fields ~w(id name iso_code)a

 def show(conn, %{"id" => id}) do
       country = Repo.get!(Country, id)
       render("show.json", country: country)

 end

 def autocomplete(conn, %{"term" => term}) do
     term = "%#{term}%"

     {:ok, %{model: Country, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
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
