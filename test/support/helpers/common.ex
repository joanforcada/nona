alias Alfred.Helpers, as: H
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

  def get_all_results(model, select_fields) do
    query = from m in model, select: map(m, ^select_fields)
    Repo.all(query)
  end

  def stringify_list([]), do: []

  def stringify_element(element) do
    H.Map.stringify_keys(element)
  end


end
