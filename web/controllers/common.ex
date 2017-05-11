defmodule Tino.Controllers.Common do
  alias Tino.Repo
  import Ecto.Query

  def build_autocomplete_query(fields, model, term, select_fields) do
    Enum.reduce(fields, model, fn {key, _value}, query ->
      from p in query, or_where: like(field(p, ^key), ^term)
    end)
    |> select(^select_fields)
    # |> select([p], struct(p, select_fields))
  end

  def add_autocomplete_result({:ok, %{model: model, term: term, fields: fields, select_fields: select_fields} = data}) do
    query = build_autocomplete_query(fields, model, term, select_fields)
    case Repo.all(query) do
      [] -> {:ok, Map.put(data, :autocomplete_result, "There are no results for this term")}
      results -> {:ok, Map.put(data, :autocomplete_result, results)}
    end
  end
end
