defmodule Mona.Test.Helpers.Currency do
  def get_sample_row(data) do
    data = data |> H.Pipe.merge([
      permalink: "23232323",
      body: %{
        "permalink" => "23ade89d",
        "name" => "https://someadblogname.com",
        "iab_codes" => ["IAB9","IAB9-23"],
        "url" => "https://theadblogurl.es",
        "bid_floor" => 0,
        "bid_floor_currency_code" => "EUR",
        "price_floor" => "",
        "categories" => ["IAB9_Hobbies & Interests","IAB9-23_Photography"],
        "pixel_url" => "",
        "pmu" => "daf9779d",
        "direct_deal_floor" => 0.0,
        "direct_deals" => [],
        "css" => "",
        "css_path" => ""
      }])

    %{
      "metadata" =>  data[:body],
      "permalink" =>  data[:permalink],
      "updated_ts" =>  1481277182826768640
    }
  end

  def insert_sample_row(data \\ []) do
    row = get_sample_row data
    Irvine.insert_into_ets_repo(:data_cache_adblogs, row["permalink"], [row])
    row
  end
end
