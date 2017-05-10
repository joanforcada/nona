defmodule Tino.Test.Helpers.Campaign do

  alias Tino.Repo
  alias Tino.Campaign

  def get_sample_row(data) do
    Map.merge(%{
      "name" => "cola",
      "permalink" => "55555555",
      "created_ts" => System.system_time(:nanoseconds),
      "updated_ts" => System.system_time(:nanoseconds)
    }, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Campaign.changeset(%Campaign{}, row)
    res = Repo.insert(changeset)

  end
end
