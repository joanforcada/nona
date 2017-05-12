defmodule Tino.Test.Helpers.Offer do

  alias Tino.Offer
  alias Tino.Repo

  def get_sample_row(data) do
    Map.merge(%{
        "name" => "some offer name",
        "permalink" => "33334444",
        "status" => "active",
        "offer_url" => "www.admanmedia.com",
        "preview_url" => "www.admanmedia.com/preview",
        "video_provider" => "html5",
        "vast_version" => 3,
        "created_ts" => System.system_time(:nanoseconds),
        "updated_ts" => System.system_time(:nanoseconds)}, data)

  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    changeset = Offer.changeset(%Offer{}, row)
    Repo.insert(changeset)
    row
  end
end
