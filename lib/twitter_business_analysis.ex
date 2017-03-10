defmodule TwitterBusinessAnalysis do

  def do_that_thang do
    # Seed the training model
    model = TrainingModel.training_model

    # Get the twitter data
   HTTPoison.start
   authorization_token = Token.token
    handle = "realdonaldtrump"

    timeline = Timeline.get(handle, 1000) |> tweets_with_sentiment(model)
    mentions = Mentions.get(handle, 1000) |> tweets_with_sentiment(model)
    user = User.get(handle) |> Map.put(
      :tweets_sentiment_percents,
      sentiment_aggregates(timeline)
    ) |> Map.put(
      :mentions_sentiment_percents,
      sentiment_aggregates(mentions)
    )

    require IEx
    IEx.pry
  end

  defp sentiment_aggregates(tweets) do
    %{
      positive: percent_sentiment(tweets, :positive),
      neutral: percent_sentiment(tweets, :neutral),
      negative: percent_sentiment(tweets, :negative)
    }
  end

  defp tweets_with_sentiment(tweets, model) do
    tweets |> Enum.map(fn (tweet) ->
      # Insert sentiment analysis into twitter data
      tweet |> Map.put(
        :sentiment,
        model |> SimpleBayes.classify_one(tweet |> Map.get(:text))
      ) |> Map.put(
        :sentiment_raw,
        model |> SimpleBayes.classify(tweet |> Map.get(:text))
      )
    end)
  end

  # Find what percent of the given tweets are the given sentiment
  defp percent_sentiment(tweets, sentiment) do
    (tweets |>
      Enum.filter(&(Map.get(&1, :sentiment) == sentiment)) |>
      Enum.count) / (tweets |> Enum.count) * 100.0
  end
end
TwitterBusinessAnalysis.do_that_thang
