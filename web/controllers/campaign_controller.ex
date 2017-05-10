defmodule Tino.CampaignController do
  use Tino.Web, :controller

 alias Tino.Campaign

 def create(conn, %{"campaign" => campaign_params}) do
    # permalink = "11111111" #Guardian.Plug.current_resource(conn)

    changeset = Campaign.changeset(%Campaign{}, campaign_params)

    case Repo.insert(changeset) do
      {:ok, campaign} ->

        conn
        |> put_status(:created)
        |> render("show.json", campaign: campaign) #retornes plantilla

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tino.ChangesetView, "error.json", changeset: changeset)
    end

  end

  def show(_conn, %{"id" => id}) do

      campaign = Repo.get!(Campaign, id)
      render("show.json", campaign: campaign)

  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do

     campaign = Repo.get!(Campaign, id)
     changeset = Campaign.changeset(%Campaign{}, campaign_params)


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

     term = "%#{Map.get(params, "term", "")}%"
     query = from(
       c in Campaign,
       where: like(c.name, ^term),
       select: %{id: c.id, name: c.name, permalink: c.permalink})
     res = Repo.all(query)
     json(conn, %{valid: true, result: res})
  end

end
