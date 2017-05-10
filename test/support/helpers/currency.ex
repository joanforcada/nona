defmodule Tino.Test.Helpers.Currency do

  alias Tino.Repo
  alias Tino.Currency

  def get_sample_row(data) do
    Map.merge(%{
        "name" => "currency1",
        "permalink" => "66666666",
        "symbol" => "80808080",
        "created_ts" => System.system_time(:nanoseconds),
        "updated_ts" => System.system_time(:nanoseconds)
    }, data)
      
  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Currency.changeset(%Currency{}, row)
    res = Repo.insert(changeset)
  end

end
