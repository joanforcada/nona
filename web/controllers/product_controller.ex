defmodule Tino.ProductController do
  use Tino.Web, :controller
  alias Tino.Controllers.Common

  # @autocomplete_fields = ["name", "product_format", "code"]
  @autocomplete_fields [name: "name", code: "code", product_format: "product_format"]
  @select_fields ~w(id name code)a

  alias Tino.Product

  def create(conn, %{"product" => product_params}) do
     permalink = "11111114" #Guardian.Plug.current_resource(conn)
     changeset = Product.changeset(%Product{}, product_params)

     case Repo.insert(changeset) do
       {:ok, product} ->

         conn
         |> put_status(:created)
         |> json(%{valid: true, result: %{permalink: product.permalink, id: product.id}}) #retornes plantilla

       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> render(Tino.ChangesetView, "error.json", changeset: changeset)
     end

   end

   def show(conn, %{"id" => id}) do
       product = Repo.get!(Product, id)
       render("show.json", product: product)

   end

   def update(conn, %{"id" => id, "product" => product_params}) do

      product = Repo.get!(Product, id)
      changeset = Product.changeset(%Product{}, product_params)


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

   def autocomplete(conn, %{"term" => term}) do
     term = "%#{term}%"

    #  auto_query = Enum.reduce(@autocomplete_fields, Product, fn {key, _value}, query ->
    #    from p in query, or_where: like(field(p, ^key), ^term)
    #  end)

    {:ok, %{model: Product, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
      |> Common.add_autocomplete_result
      |> build_response

   end

   def build_response({:ok, %{conn: conn, autocomplete_result: res}}) do
     json(conn, %{valid: true, result: res})
   end
end
