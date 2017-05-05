defmodule Tino.OfferController do
use Tino.Web, :controller

alias Tino.Offer

 def create(conn, %{"offers" => offer_params}) do
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

  def show (conn, %{"id" => id}) do
      offer = Repo.get!(Offer, id)  
      render("show.json", offer: offer)

  end

  def update (conn, %{"id" => id, "offers" => offers_params}) do

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
end
