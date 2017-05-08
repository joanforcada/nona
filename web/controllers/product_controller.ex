defmodule Tino.ProductController do
  use Tino.Web, :controller

  # @autocomplete_fields = ["name", "product_format", "code"]

  alias Tino.Product

  def create(conn, %{"product" => product_params}) do
     permalink = "11111114" #Guardian.Plug.current_resource(conn)
     changeset = Product.changeset(%Product{}, product_params)

     case Repo.insert(changeset) do
       {:ok, product} ->

         conn
         |> put_status(:created)
         |> render("show.json", product: product) #retornes plantilla

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

   def autocomplete(conn, params) do

        # for sf <- @autocomplete_fields do
        #   like(sf, "%#{params["term"]}%")
        # end
        # autocomplete_fields
        like_value = "%Seeding%"

        query = from(p in Product, where: like(p.name, ^like_value), select: [p.name, p.code])
        res = Repo.all(query)
        json(conn, %{valid: true, result: res})
   end


    # update repo and redirect accordingly



end
