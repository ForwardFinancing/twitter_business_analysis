defmodule CollectionRequest do
  def get(endpoint, params, max \\ 1000, count \\ 200, path \\ []) do
    do_get(endpoint, params, max, count, nil, path)
  end

  defp do_get(endpoint, params, max, count, max_id, path \\ [], acc \\ []) do
    params = params |> Map.put("count", count)
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
        endpoint,
        [],
        params: params
      ).body

      # If the part of the map we want is nested within the response, traverse
      #   the response map by the given path until we get to the good stuff
      response = Enum.reduce(path, response, fn (path, map) ->
        map |> Map.get(path)
      end)

      min_id = response |> Enum.min_by(&(Map.get(&1, "id"))) |> Map.get("id")
      # Recursion! Use the min_id as the max for the next request, and add the
      #   block of responses to the accumulator.
      do_get(
        endpoint,
        params,
        max,
        count,
        min_id,
        path,
        acc ++ (response |> Enum.map(&(TweetResponse.process_response(&1))))
      )
    end
  end
end
