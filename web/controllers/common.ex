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

  def add_update_result({:ok, %{changeset: changeset, conn: conn}} ) do

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


  def add_create_result({:ok, %{model: model, changeset: changeset, conn: conn, select_fields: select_fields}}) do

    changes = changeset
      |> generate_unique_id(model)
      |> touch_created_ts
      |> touch_updated_ts

    case Repo.insert(changes) do
      {:ok, res} ->
        result = Map.take(res, select_fields)
        conn
        |> json(%{valid: true, result: result})
        # |> render("show.json", :model)
      {:error, changeset} ->
        conn
        |> json(%{valid: false, result: changeset})
          # |> render(Tino.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def errors do
    @errors
  end

  defp touch_created_ts(changeset) do
    Ecto.Changeset.put_change(changeset, :created_ts, System.system_time(:nanoseconds))
  end

  def touch_updated_ts(changeset) do
    Ecto.Changeset.put_change(changeset, :updated_ts, System.system_time(:nanoseconds))
  end

  def generate_unique_id(changeset, model) do
    id = System.system_time(:nanoseconds)
    query = from(m in model, where: m.id == ^id, select: %{id: m.id})
    res = Repo.all(query)
    case res do
      [] -> Ecto.Changeset.put_change(changeset, :id, id)
      _ -> generate_unique_id(changeset, model)
    end
  end
  def generate_unique_permalink(changeset, model) do
    # changeset
    permalink = H.String.hex(4)
    query = from(m in model, where: m.permalink == ^permalink, select: %{permalink: m.permalink})

    res = Repo.all(query)

    case res do
      [] -> Ecto.Changeset.put_change(changeset, :permalink, permalink)
      _ -> generate_unique_permalink(changeset, model)
    end
  end
end
