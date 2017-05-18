require Alfred.Helpers, as: H
defmodule Tino.OfferController do
  use Tino.Web, :controller

  alias Tino.Offer
  alias Tino.Controllers.Common

  def create(conn, %{"offer" => offer_params}) do
    # permalink = "11111111" #Guardian.Plug.current_resource(conn)


    changeset = Offer.changeset(%Offer{}, offer_params)
      |> Common.generate_unique_permalink(Offer)
    # campaign_params = %{"permalink" => <value>}
    # changeset = Campaign.changeset(%Campaign{}, campaign_params)
    {:ok, %{model: Offer, changeset: changeset, conn: conn, select_fields: Offer.select_fields}}
      |>Common.add_create_result

  end

  def show(conn, %{"id" => id}) do
      offer = Repo.get!(Offer, id)
      render("show.json", offer: offer)

  end

  def update(conn, %{"id" => id, "params" => offer_params}) do

      {:ok, %{id: id, model: Offer, params: offer_params, conn: conn}}
      |> Common.add_update_result


  end

  def autocomplete(conn, %{"term" => term}) do
    term = "%#{term}%"

    {:ok, %{model: Offer, term: term, fields: Offer.autocomplete_fields, select_fields: Offer.select_fields, conn: conn}}
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
