defmodule Tino.Country do
  use Tino.Web, :model

  schema "countries" do

    field :name, :string
    field :iso_code, :string

    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :iso_code, :created_ts, :updated_ts])
  end

end
