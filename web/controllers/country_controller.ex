defmodule Tino.CountryController do
  use Tino.Web, :controller

  alias Tino.Country

  def create(conn, %{"country" => purchase_orders_params}) do
     #permalink = "11111113" #Guardian.Plug.current_resource(conn)
     changeset = Country.changeset(%Country{}, country_params)

     case Repo.insert(changeset) do
       {:ok, country_params} ->

         conn
         |> put_status(:created)
         |> render("show.json", country: country) #retornes plantilla

       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> render(Tino.ChangesetView, "error.json", changeset: changeset)
     end

   end

   def show (conn, %{"id" => id}) do
       country = Repo.get!(Country, id)
       render("show.json", country: country)

   end

   def update (conn, %{"id" => id, "country" => country_params}) do

      country = Repo.get!(Country, id)
      changeset = Country.changeset(%Country{}, country_params)


     Repo.update(changeset)
       #{:ok, campaign} ->

       #  conn
       #  |> put_status(:created)
       #  |> render("show.json", campaign: campaign) #retornes plantilla

       #{:error, changeset} ->
       #  conn
       #  |> put_status(:unprocessable_entity)
       #  |> render(Tino.ChangesetView, "error.json", changeset: changeset)

   end

end
