require Alfred.Helpers, as: H
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

   def autocomplete(conn, %{"term" => term}) do
     term = "%#{term}%"
     fields = [name: "name", code: "code", product_format: "product_format"]

     auto_query = Enum.reduce(fields, Product, fn {key, _value}, query ->
       from p in query, or_where: like(field(p, ^key), ^term)
     end)
      |> select([p, _], %{id: p.id, name: p.name, code: p.code})

     res = Repo.all(auto_query)

    #  res = Repo.all(q_def)
    #  query = from(
    #      p in Product,
    #      where: like(p.name, ^term) or like(p.code, ^term) or like(),
    #      select: %{id: p.id, name: p.name, code: p.code})
    #  res = Repo.all(auto_query)
     json(conn, %{valid: true, result: res})
   end

  #  def compose_query(fields, model, term) do
  #    Enum.reduce(fields, model, fn {_key, value}, query ->
  #      from p in query, or_where: like(^p."#{value}", ^term)
  #    end)
  #  end

  #  def compose_query(model, field, term) do
  #    from(p in model, or_where: like(^field, ^term))
  #  end

  #  def loop_query(model, fields, term) do
  #    Enum.reduce(fields, model, &compose_query())
  #  end



   def autocomplete(conn, _params) do
     json(conn, %{valid: false, result: "Param 'term' is missing"})
   end
  # update repo and redirect accordingly



end
