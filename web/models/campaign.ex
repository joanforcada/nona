defmodule Tino.Campaign do
  use Tino.Web, :model

  schema "campaigns" do
    field :name, :string
    field :permalink, :string

    belongs_to :enterprise, Tino.Enterprise
    has_many :offers, Tino.Offer

    field :created_ts, :integer
    field :updated_ts, :integer
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :permalink, :created_ts, :updated_ts])
  end

end
