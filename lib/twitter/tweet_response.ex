defmodule TweetResponse do
  @doc """
    Given a raw status hash from the API response, picks out the fields that we
    actually care about.
  """
  def process_response(status) do
    %{
      hashtags: status["entities"]["hashtags"],
      tweet_time: status["created_at"],
      favorited_count: status["favorite_count"],
      tracked_location: status["geo"],
      text: status["text"], #TODO remove urls, hashtags, and mentions?,
      mentions: mentions(status["entities"]["user_mentions"]),
      retweet_count: status["retweet_count"]
    }
  end

  defp mentions(user_mentions) do
    "Not yet implemented"
  end
end
