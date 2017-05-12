defmodule Tino.Test.Helpers.Common do

  alias Tino.Repo
  import Ecto.Query

  def build_results(fields, model, term, select_fields) do
    term = "%#{term}%"
    auto_query =
    Enum.reduce(fields, model, fn key, query ->
      from po in query, or_where: like(field(po, ^key), ^term)
    end)
    |> select([po], map(po, ^select_fields))
    res = Repo.all(auto_query)

    case res do
      [] -> "There are no results for this term"
      results -> results
    end
  end
end
