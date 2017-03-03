defmodule User do
  @moduledoc """
    Return aggregate summary information about a user and their latest tweet
  """
  def get(handle) do
    Request.get!(
      "/1.1/users/show.json?screen_name=#{handle}&include_entities=true"
    ).body |> process_response
  end

  defp process_response(response) do
    %{
      private_account: response["protected"],
      following_count: response["friends_count"],
      followers_count: response["followers_count"],
      verified_account: response["verified"],
      tweets_count: response["statuses_count"],
      lists_included_in_count: response["listed_count"],
      alleged_location: response["location"],
      account_created_at: response["created_at"],
      name: response["name"],
      handle: response["screen_name"],
      description: response["description"],
      favorites_count: response["favourites_count"],
      last_tweet: last_tweet(response["status"])
    }
  end

  defp last_tweet(status) do
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
