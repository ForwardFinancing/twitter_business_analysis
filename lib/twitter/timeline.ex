defmodule Timeline do

  def get(handle, max \\ 1000) do
    CollectionRequest.get(
      "1.1/statuses/user_timeline.json",
      %{
        "screen_name" => handle
      },
      max
    )
  end
end
