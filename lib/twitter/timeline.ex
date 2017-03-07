defmodule Timeline do

  def get(handle, max \\ 1000) do
    # 200 is max page size currently
    get(handle, max, 200)
  end

  defp get(handle, max, count) do
    get(handle, max, count, nil)
  end

  defp get(handle, max, count, max_id, acc \\ []) do
    params = %{
      "screen_name" => handle,
      "count" => count
    }
    # Twitter uses max_id to facilitate pagination. For the first request, there
    #   is no max id. For future requests, the max_id is the minimum id of the
    #   last request.
    if max_id do
      params = params |> Map.put("max_id", max_id)
    end
    if Enum.count(acc) >= max do
      # TODO must provide max for now, need to find a way to break if
      #   no more tweets to return
      # Since we might have a few extra tweets, return the first `max` tweets
      acc |> Enum.take(max)
    else
      response = Request.get!(
        "1.1/statuses/user_timeline.json",
        [],
        params: params
      ).body
      min_id = response |> Enum.min_by(&(Map.get(&1, "id"))) |> Map.get("id")
      # Recursion! Use the min_id as the max for the next request, and add the
      #   block of responses to the accumulator.
      get(
        handle,
        max,
        count,
        min_id,
        acc ++ (response |> Enum.map(&(TweetResponse.process_response(&1))))
      )
    end
  end
end
