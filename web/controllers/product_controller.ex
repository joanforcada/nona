defmodule Tino.ProductController do
  use Tino.Web, :controller

  alias Tino.Product
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name code product_format)a
  @select_fields ~w(id name code)a

    def create(conn, %{"product" => product_params}) do

      changeset = Product.changeset(%Product{}, product_params)
      {:ok, %{model: Product, changeset: changeset, conn: conn}}
      |>Common.add_create_result

    end

   def show(conn, %{"id" => id}) do
     product = Repo.get!(Product, id)
     render("show.json", product: product)
   end

   def update(conn, %{"id" => id, "params" => product_params}) do

       {:ok, %{id: id, model: Product, params: product_params, conn: conn}}
       |> Common.add_update_result

   end

   def autocomplete(conn, %{"term" => term}) do
     term = "%#{term}%"

    {:ok, %{model: Product, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
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
