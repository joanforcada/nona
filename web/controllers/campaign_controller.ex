require Alfred.Helpers, as: H
defmodule Tino.CampaignController do
  use Tino.Web, :controller

  alias Tino.Campaign
  alias Tino.Controllers.Common

  @autocomplete_fields ~w(name permalink)a
  @select_fields ~w(id name permalink)a

  def create(conn, %{"campaign" => campaign_params}) do
    # permalink = "11111111" #Guardian.Plug.current_resource(conn)
    permalink = H.hex(4)
    Map.put(campaign_params, "permalink", permalink)
    IO.inspect(campaign_params)
    # campaign_params = %{"permalink" => <value>}
    # changeset = Campaign.changeset(%Campaign{}, campaign_params)
    {:ok, %{model: Campaign, params: campaign_params, conn: conn}}
    |>Common.add_create_result

  end

  def show(conn, %{"id" => id}) do

      campaign = Repo.get!(Campaign, id)
      render("show.json", campaign: campaign)

  end

  def update(conn, %{"id" => id, "params" => campaign_params}) do
      {:ok, %{id: id, model: Campaign, params: campaign_params, conn: conn}}
      |> Common.add_update_result
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
