require Alfred.Helpers, as: H
defmodule Tino.ProductController do
  use Tino.Web, :controller

  alias Tino.Product
  alias Tino.Controllers.Common

  def create(conn, %{"product" => product_params}) do
    changeset = Product.changeset(%Product{}, product_params)

    {:ok, %{model: Product, changeset: changeset, conn: conn, select_fields: Product.select_fields}}
    |> Common.add_create_result
  end

  def show(conn, %{"id" => id}) do
    product = Repo.get!(Product, id)
    render("show.json", product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do

    case Repo.get!(Product, id) do
      %Product{} = res ->
        changeset = Product.changeset(res, product_params)
        {:ok, %{changeset: changeset, conn: conn, select_fields: Product.select_fields}}
        |> Common.add_update_result
    end
  end

  def autocomplete(conn, %{"term" => term}) do
    term = "%#{term}%"

    {:ok, %{model: Product, term: term, fields: Product.autocomplete_fields, select_fields: Product.select_fields, conn: conn}}
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
