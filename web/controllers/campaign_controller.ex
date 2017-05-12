defmodule Tino.CampaignController do
  use Tino.Web, :controller

  alias Tino.Campaign
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name permalink)a
  @select_fields ~w(id name permalink)a

  def create(conn, %{"campaign" => campaign_params}) do
    # permalink = "11111111" #Guardian.Plug.current_resource(conn)

    changeset = Campaign.changeset(%Campaign{}, campaign_params)

    case Repo.insert(changeset) do
      {:ok, campaign} ->

        conn
        |> put_status(:created)
        |> json(%{valid: true, result: %{permalink: campaign.permalink, id: campaign.id}}) #retorne#retornes plantilla

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

  def autocomplete(conn, %{"term" => term}) do
    term = "%#{term}%"

    {:ok, %{model: Campaign, term: term, fields: @autocomplete_fields, select_fields: @select_fields, conn: conn}}
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
