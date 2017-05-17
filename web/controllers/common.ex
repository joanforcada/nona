require Alfred.Helpers, as: H


defmodule Tino.Controllers.Common do

  use Tino.Web, :controller
  use Phoenix.Controller
  alias Tino.Repo
  import Ecto.Query


  @errors %{

    missing_term: %{valid: false, result: "Param 'term' is required"}

  }

  def build_autocomplete_query(fields, model, term, select_fields) do
    Enum.reduce(fields, model, fn key, query ->
      from p in query, or_where: like(field(p, ^key), ^term)
    end)
    |> select([p], map(p, ^select_fields))
  end

  def add_autocomplete_result({:ok, %{model: model, term: term, fields: fields, select_fields: select_fields} = data}) do
    query = build_autocomplete_query(fields, model, term, select_fields)
    case Repo.all(query) do
      [] -> {:ok, Map.put(data, :autocomplete_result, "There are no results for this term")}
      results -> {:ok, Map.put(data, :autocomplete_result, results)}
    end
  end

  def add_update_result({:ok, %{id: id, model: model, params: params, conn: conn}} ) do

    #product = Repo.get!(Product, id)
    model_result = Repo.get!(model, id)
    changeset = Ecto.Changeset.change(model_result, params)

    case Repo.update(changeset) do
      {:ok, res} ->
        conn
        |> put_status(:update)
        |> render("show.json", :model) #retornes plantilla

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tino.ChangesetView, "error.json", changeset: changeset)
      end
  end


  def add_create_result({:ok, %{model: model, params: params, conn: conn}} ) do

    changeset = model.changeset(%model{}, params)

    case Repo.insert(changeset) do
      {:ok, model} ->
        conn
        |> put_status(:created)
        |> render("show.json", :model)
        #|> json(conn, %{valid: true, result: model})
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Tino.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def errors do
    @errors
  end
end
