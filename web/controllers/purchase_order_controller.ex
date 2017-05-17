defmodule Tino.PurchaseOrderController do
  use Tino.Web, :controller

  alias Tino.PurchaseOrder
  alias Tino.Controllers.Common

  #Fields which to look for when performing autocomplete
  @autocomplete_fields  ~w(number description)a
  # Fields to select from the database (for autocomplete only (for now))
  @select_fields ~w(id number description)a


  def create(conn, %{"purchase_order" => purchase_order_params}) do
    # permalink = "11111111" #Guardian.Plug.current_resource(conn)
    # campaign_params = %{"permalink" => <value>}
    changeset = PurchaseOrder.changeset(%PurchaseOrder{}, purchase_order_params)
    # campaign_params = %{"permalink" => <value>}
    # changeset = Campaign.changeset(%Campaign{}, campaign_params)
    {:ok, %{model: PurchaseOrder, changeset: changeset, conn: conn}}
      |>Common.add_create_result

  end

  def show(conn, %{"id" => id}) do
    purchase_order = Repo.get!(PurchaseOrder, id)
    render("show.json", purchase_order: purchase_order)

  end

  def update(conn, %{"id" => id, "params" => purchase_order_params}) do

      {:ok, %{id: id, model: PurchaseOrder, params: purchase_order_params, conn: conn}}
      |> Common.add_update_result


  end
  @doc """
    Searches in the database for any matches with the parameter term from the URL
    Exmaple:
      autocomplete(conn, %{"term" => 34904})
      %{valid: true, result: [%{PurchaseOrder}]}
  """
  def autocomplete(conn, %{"term" => term}) do
    term = "%#{term}%"

   {:ok, %{model: PurchaseOrder, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
     |> Common.add_autocomplete_result
     |> build_response

  end

  def autocomplete(conn, _params) do
    json(conn, Map.get(Common.errors, :missing_term))
  end

  @doc """
    Builds the response to return after the action has been performed (autocomplete for now)
    Exmaple:
      build_response({:ok, %{conn: conn, autocomplete_result: [%{PurchaseOrder}]})
      %{valid: true, result: [%{PurchaseOrder}]}
  """

  def build_response({:ok, %{conn: conn, autocomplete_result: res}}) do
    json(conn, %{valid: true, result: res})
  end

end
