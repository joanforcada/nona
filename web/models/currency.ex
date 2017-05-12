defmodule Tino.Currency do
  use Tino.Web, :model

  schema "currencies" do

    field :name, :string
    field :code, :string
    field :symbol, :string

    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :code, :symbol, :created_ts, :updated_ts])
  end

end
