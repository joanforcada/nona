defmodule Micampaings.Campaings do
  use Micampaings.Web, :model

  schema "campaings" do
    field :name, :string
    field :permalink, :integer
  
    belongs_to :enterprise, Sling.enterprise
    has_many :offer, Sling.offer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
  end

end
