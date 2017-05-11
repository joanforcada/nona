defmodule Tino.CampaignController do
  use Tino.Web, :controller

  @autocomplete_fields [name: "name", permalink: "permalink"]
  @select_fields ~w(id name permalink)a

  alias Tino.Campaign
  alias Tino.Controllers.Common

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

    # auto_query = Enum.reduce(@autocomplete_fields, Campaign, fn {key, _value}, query ->
    #   from p in query, or_where: like(field(p, ^key), ^term)
    # end)
    #  |> select([p, _], %{id: p.id, name: p.name, permalink: p.permalink})
    #
    # res = Repo.all(auto_query)
    #
    # json(conn, %{valid: true, result: res})
  end

  def build_response({:ok, %{autocomplete_result: res, conn: conn}}) do
    IO.inspect res
    json(conn, %{valid: true, result: res})
  end

end
