
defmodule Mona.Test.Helpers.Offer do
  alias Tino.Offer
  def get_sample_row(data \\ []) do
      sample = %{
          "permalink" => "23232323",
          "status" => "active",
          "countries" => ~w(ES CA BR),
          "currency" => "EUR",
          "duration" => "20",
          "conversion_second" => 0,
          "name" => "Dummy You",
          "target" => "desktop",
          "description" => "Offer with events",
          "offer_url" => "http://somedomain.com",
          "video_duration"=>0,
          "priority"=>0.0,
          "video_provider"=>"html5",
          "video_url"=>"",
          "vpaid_tag"=>"",
          "impression_tag_url"=>"http://thisisnottheimpressiontagyouarelookingfor.com",
          "video_tag_time_perc"=>20.0,
          "force_video_not_available"=>false,
          "vast_version"=>3,
          "budget"=>449.999988079071,
        }

      Map.merge(sample, data)
  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Offer.changeset(%Offer{}, row)
    Repo.insert(changeset)
  end

  # schema "offers" do
    # field :permalink, :integer
    # field :budget,  :integer
    # field :status,  :string
    # field :offer_url,  :string
    # field :preview_url,  :string
    # field :video_type, :string
    # field :vast_version, :integer
    # belongs_to :campaign, Tino.Campaign
    # belongs_to :product, Tino.Product
    # many_to_many :countries, Tino.Country, join_through: "countries_offers"
    # many_to_many :purchase_orders, Tino.PurchaseOrder, join_through: "offer_shares", on_delete: :delete_all

    # timestamps()
  # end

  def get_sample_body() do

  end
end
