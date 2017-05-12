require Alfred.Helpers, as: H
defmodule Tino.OfferController do
  use Tino.Web, :controller
  
  alias Tino.Offer
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name permalink)a
  @select_fields ~w(id name permalink)a

  def create(conn, %{"offer" => offer_params}) do
    permalink = "11111112" #Guardian.Plug.current_resource(conn)
    changeset = Offer.changeset(%Offer{}, offer_params)

    case Repo.insert(changeset) do
      {:ok, offer} ->

        conn
        |> put_status(:created)
        |> render("show.json", offer: offer) #retornes plantilla

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tino.ChangesetView, "error.json", changeset: changeset)
    end

  end

  def show(conn, %{"id" => id}) do
      offer = Repo.get!(Offer, id)
      render("show.json", offer: offer)

  end

  def update(conn, %{"id" => id, "offer" => offer_params}) do

     offer = Repo.get!(Offer, id)
     changeset = Offer.changeset(%Offer{}, offer_params)


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

    {:ok, %{model: Offer, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
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
