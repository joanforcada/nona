defmodule Tino.Currency do
  use Tino.Web, :model

  schema "currencies" do

    field :name, :string
    field :code, :string
    field :symbol, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :code, :symbol])
  end

end
