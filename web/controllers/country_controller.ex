defmodule Tino.CountryController do
  use Tino.Web, :controller

  alias Tino.Country
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name iso_code)a
  @select_fields ~w(id name iso_code)a

  def create(conn, %{"country" => country_params}) do
     #permalink = "11111113" #Guardian.Plug.current_resource(conn)
     changeset = Country.changeset(%Country{}, country_params)

     case Repo.insert(changeset) do
       {:ok, country} ->

         conn
         |> put_status(:created)
         |> render("show.json", country: country) #retornes plantilla

       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> render(Tino.ChangesetView, "error.json", changeset: changeset)
     end

   end

   def show(conn, %{"id" => id}) do
       country = Repo.get!(Country, id)
       render("show.json", country: country)

   end

   def update(conn, %{"id" => id, "country" => country_params}) do

      country = Repo.get!(Country, id)
      changeset = Ecto.Changeset.change(country, country_params)


      case Repo.update(changeset) do
        {:ok, country} ->
          conn
          |> put_status(:created)
          |> build_response()

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Tino.ChangesetView, "error.json", changeset: changeset)
      end

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
