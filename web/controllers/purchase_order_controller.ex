defmodule Tino.PurchaseOrderController do
  use Tino.Web, :controller

 alias Tino.PurchaseOrder

 def create(conn, %{"purchase_order" => purchase_order_params}) do
    permalink = "11111113" #Guardian.Plug.current_resource(conn)
    changeset = PurchaseOrder.changeset(%PurchaseOrder{}, purchase_order_params)

    case Repo.insert(changeset) do
      {:ok, purchase_order} ->

        conn
        |> put_status(:created)
        |> render("show.json", purchase_order: purchase_order) #retornes plantilla

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tino.ChangesetView, "error.json", changeset: changeset)
    end

  end

  def show(conn, %{"id" => id}) do
      purchase_order = Repo.get!(PurchaseOrder, id)
      render("show.json", purchase_order: purchase_order)

  end

  def update(conn, %{"id" => id, "purchase_order" => purchase_order_params}) do

     purchase_order = Repo.get!(PurchaseOrder, id)
     changeset = PurchaseOrder.changeset(%PurchaseOrder{}, purchase_order_params)


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
