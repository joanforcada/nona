defmodule Tino.Campaign do
  use Tino.Web, :model

  schema "campaigns" do
    field :name, :string
    field :permalink, :integer

    belongs_to :enterprise, Tino.Enterprise
    has_many :offers, Tino.Offer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :enterprise_id])
  end

end
