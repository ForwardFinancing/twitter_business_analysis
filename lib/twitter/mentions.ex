defmodule Mentions do
  def get(handle, max \\ 1000) do
    CollectionRequest.get(
      "1.1/search/tweets.json",
      %{
        "q" => "@#{handle}"
      },
      max,
      100, # page size limit is 100 for this endpoint
      ["statuses"]
    )
  end
end
