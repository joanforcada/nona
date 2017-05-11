defmodule Tino.Test.Helpers.Country do

  alias Tino.Country
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
      "name" => "country_1",
      "iso_code" => "44444444",
      "created_ts" => System.system_time(:nanoseconds),
      "updated_ts" => System.system_time(:nanoseconds)}, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Country.changeset(%Country{}, row)
    Repo.insert(changeset)
    row
  end
end
