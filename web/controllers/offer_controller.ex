defmodule Tino.OfferController do
use Tino.Web, :controller

alias Tino.Offer

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

  def autocomplete(conn, %{"term"=> term}) do
     term = "%#{term}%"
     query = from(
       o in Offer,
       where: like(o.permalink, ^term),
       select: %{id: o.id, permalink: o.permalink, status: o.status, offer_url: o.offer_url, preview_url: o.preview_url, video_provider: o.video_provider, vast_version: o.vast_version})
     res = Repo.all(query)
     json(conn, %{valid: true, result: res})
  end

  def autocomplete(conn, _params) do
    json(conn, %{valid: false, result: "Param 'term' is missing"})
  end
end
